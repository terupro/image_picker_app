import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image; // 取り込んだ画像パスを取得
  final picker = ImagePicker(); // ImagePickerのインスタンス生成

  // 画像の取り込み
  Future pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        // Imageウィジェットにimageを渡せば表示できる
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // 画像の保存
  Future saveImage() async {
    if (image != null) {
      final Uint8List buffer = await image!.readAsBytes(); //画像データの配列を取得
      final result = await ImageGallerySaver.saveImage(buffer); //アルバムに保存
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image != null
              ? Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        saveImage();
                        showOkAlertDialog(
                          context: context,
                          title: 'アルバムに保存されました',
                        );
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ClipOval(
                      child: Image.file(
                        image!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                )
              : const FlutterLogo(size: 160),
          const SizedBox(height: 10.0),
          const Text(
            'Image Picker',
            style: TextStyle(
              fontSize: 47.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50.0),
          ButtonWidget(
            label: 'Pick Gallery',
            icon: Icons.image_outlined,
            press: () => pickImage(ImageSource.gallery),
          ),
          ButtonWidget(
            label: 'Pick Camera',
            icon: Icons.camera_alt_outlined,
            press: () => pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.press,
    required this.icon,
    required this.label,
  }) : super(key: key);
  final VoidCallback? press;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
