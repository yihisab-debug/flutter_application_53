import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Message {
  final String id;
  final String Name;
  final String Text;
  final String Time;

  Message({
    required this.id,
    required this.Name,
    required this.Text,
    required this.Time,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      Name: json['Name'],
      Text: json['Text'],
      Time: json['Time'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _login() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите имя')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactsScreen(
          myName: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.person, size: 100, color: Colors.white),

              const SizedBox(height: 30),

              const Text(
                'Добро пожаловать',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: 'Введите имя',
                  hintStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onSubmitted: (_) => _login(),
              ),

              const SizedBox(height: 25),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.indigoAccent,
                    ),
                  ),

                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final String myName;

  const ContactsScreen({super.key, required this.myName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('Контакты', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            ContactTile(
              myName: myName,
              contactName: 'Alex',
              textColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 54, 54, 54),
              borderColor: Colors.blueGrey,
            ),

            const SizedBox(height: 12),

            ContactTile(
              myName: myName,
              contactName: 'Maria',
              textColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 54, 54, 54),
              borderColor: Colors.blueGrey,
            ),

          ],
        ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String myName;
  final String contactName;
  final Color avatarColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const ContactTile({
    super.key,
    required this.myName,
    required this.contactName,
    this.avatarColor = Colors.blue,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Icon(Icons.person, color: Colors.white),
        ),

        title: Text(
          contactName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: Icon(Icons.chat, color: avatarColor),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                myName: myName,
                contactName: contactName,
              ),
            ),

          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String myName;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.myName,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String baseUrl =
      'https://6939834cc8d59937aa082275.mockapi.io/image';

  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        messages = (json.decode(response.body) as List)
            .map((e) => Message.fromJson(e))
            .toList();
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Name": widget.myName,
        "Text": _textController.text.trim(),
        "Time": DateTime.now().toString(),
      }),
    );

    _textController.clear();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('Чат', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isleft = msg.Name == 'Alex';

                      return Align(
                        alignment: isleft
                            ? Alignment.centerLeft
                            : Alignment.centerRight,

                        child: Column(
                          crossAxisAlignment: isleft
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 4,
                              ),

                              child: Text(
                                msg.Name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),

                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 124, 141, 237),
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Text(
                                msg.Text,
                                style: const TextStyle(color: Colors.white),
                              ),

                            ),

                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      hintText: 'Сообщение',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),

                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigoAccent),
                  onPressed: sendMessage,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}