From: Debasis.Ratha@lntinfotech.com
Subject: Doubt on PPP!
Date: Mon, 27 May 2002 10:23:32 +0530
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFF5A9B733.BC7A8850-ON65256BC6.001A4E24@LocalDomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=65256BC6001A4E248f9e8a93df938690918c65256BC6001A4E24"
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

--0__=65256BC6001A4E248f9e8a93df938690918c65256BC6001A4E24
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: quoted-printable


Hi All,
I have a doubt on PPP over serial. Can you please help me out...
My doubt goes like this;

Test Set-Up:
(Embedded image moved to file: pic00041.pcx)
System Details: All the three machines are standard Pentium PCs with
Linux-2.4.2 loaded. The PPP has been enabled in machine-1 and machine-3=
.

Requirement: Is to establish a PPP session between machine-1 and machin=
e-3.
Machine-2 should do nothing with the PPP frame. It should receive the P=
PP
frame on the serial and maybe send it to machine-3 on the Ethernet.

Approach: Have written a small module in machine-2, that should receive=
 the
PPP frame from the serial interface and send it on the Ethernet interfa=
ce.
Also tested the module on machine-2 with a simulator working from machi=
ne-1
(instead of the actual PPP). The simulator would send packets of varied=

sizes, from 3 bytes upto 1500 bytes, with the header and trailer as the=

same no. like 7E as in ppp. For the simulator the character 7E wasn't
repeated anywhere inside the data.

Tests and Findings:  With the simulator, the module seems to work fine,=
  if
anything less than 8 bytes is sent, the module in machine-2 receives it=
 in
one go. If anything above 8-bytes, the machine-2 module receives it
multiple times, but the logic in the module converts it into a single
message and sends it on the ethernet using UDP to machine-3. when runni=
ng
the actual PPP module from machine-1, the module behaves erroneously. P=
PP
has header and trailer as 7E but the module is printing characters like=
 4f.

If anyone has done similar testings, can u please point out what the
problem could be with respect to PPP. Or is there any better way of doi=
ng
whatever I am trying to do. The requirement section would help u people=
 in
knowing what is required.

=

--0__=65256BC6001A4E248f9e8a93df938690918c65256BC6001A4E24
Content-type: application/octet-stream;
	name="pic00041.pcx"
Content-Disposition: attachment; filename="pic00041.pcx"
Content-transfer-encoding: base64

CgUBCAAAAAAQApsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAABEQIBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAD//////////8L/yQD////////n/9T/yv/F/8L/wf/////////6/8UAzv/E
AP///////+T/0v/J/8T/wv/B//////////T/xADb/wD////////i/9H/yf/E/8L/wf/////////x
/wDi/8QA////////4P/Q/8j/xP/C/8H/////////7v/EAOj/wgD//////v/f/8//yP/E/8L/////
////6/8A8P/CAP/////9/97/z//I/8T/wv/////////q/wD////////3/9v/zv/H/8P/wv//////
///o/8IA9v/EAP/////6/93/zv/H/8T/wv///////////////////+3/1v/L/8b/w//B////////
/+X/AP//wf8A//////j/3P/O/8f/xP/C////////////5//DAP/////3/9z/zv/H/8P/wv//////
/////+n/wgD/////9//b/87/x//D/8L/////////3/8A/////////P/e/8//yP/E/8L/////////
3v/CAP//zf8A//////X/2//N/8f/w//C/////////9z/wwD//8//AP/////1/9r/zf/H/8P/wv//
/////////+//AP/////0/9r/zf/H/8P/wv/////////a/wD//////////9//0P/I/8T/wv//////
///Z/8IA///////////f/9D/yP/E/8L/////////2P/CAP//2f8A//////L/2f/N/8b/w//C////
/////9f/wgD//9v/AP/////y/9n/zP/G/8P/wv///////////////////+3/1v/L/8b/w//B////
/////9X/AP//////////4v/R/8j/xP/C/8H/////////1f8A///////////i/9H/yP/E/8L/wf//
///////U/wD//+P/AP/////w/9j/zP/G/8P/wf////////////n/AP/////v/9j/zP/G/8P/wf//
/////////////////+3/1v/L/8b/w//B/////////9H/AP//////////5P/S/8n/xP/C/8H/////
////0P/CANX/xfzu/8T8x//C/NP/AP/////u/9f/zP/G/8P/wf/////////P/8IA1f/B/MX/wfzs
/8H8xP/B/MX/wfzW/wD/////7v/X/8v/xv/D/8H/////////zv/CANX/wfzH/8H86v/B/Mb/wfzE
/8H81/8A/////+3/1//L/8b/w//B/////////+X/wfzM/8P8xf/D/MT/wfzB/8P8xv/D/Mj/wfzI
/8H8wv/E/NX/AP/////t/9f/y//G/8P/wf/////////N/wDY/8H8yv/B/MP/wfzD/8H8w//B/MP/
wvzD/8H8xP/B/MP/wfzH/8H8yP/B/MP/wfz/////+f/d/87/x//E/8L/////////zf8A2f/D/Mb/
wfzH/8H8xf/B/ML/wfzF/8H8wv/B/MX/wfzG/8H8yP/B/MP/wfz/////+f/d/87/x//E/8L/////
////zf8A3P/D/MP/wfzH/8H8xf/B/ML/wfzF/8H8wv/B/MX/wfzG/8H8yP/B/MP/wfzZ/wD/////
7P/W/8v/xv/D/8H/////////zP8A4P/B/ML/wfzH/8H8xf/B/ML/wfzF/8H8wv/H/Mb/wfzI/8H8
w//B/Nr/AP/////s/9b/y//F/8P/wf/////////L/wDh/8H8wv/B/Mf/wfzF/8H8wv/B/MX/wfzC
/8H8zP/B/Mj/wfzD/8H82v8A/////+z/1v/L/8X/w//B/////////+X/wfzH/8H8wv/B/Mf/wfzF
/8H8wv/B/MX/wfzC/8H8xf/B/Mf/wfzG/8H8xP/B/P/////5/93/zv/H/8T/wv/////////m/8H8
xf/B/MT/wfzD/8H8w//B/MP/wfzD/8L8w//B/MT/wfzD/8H8yf/B/MT/wfzF/8H8//////n/3f/O
/8f/xP/C/////////8r/ANz/xfzG/8P8xf/D/MT/wfzB/8P8xv/D/Mv/xPzG/8H83P8A/////+v/
1f/L/8X/w//B/////////8r/APb/wfz//8H/AP/////q/9X/y//F/8P/wf/////////J/wD3/8H8
///B/wD/////6v/V/8v/xf/D/8H/////////yP8A+P/B/P//wf8A/////+r/1f/L/8X/w//B////
////////////////7f/W/8v/xv/D/8H/////////x/8A///////////p/9T/yv/F/8P/wf//////
///H/wD///z/AP/////q/9X/yv/F/8P/wf/////////H/wDr/8H8xv/B/Mb/wfzQ/8H88P/CAP//
///p/9X/yv/F/8P/wf/////////H/wDr/8H8xf/B/MH/wfzF/8H80P/B/PH/AP/////p/9X/yv/F
/8P/wf/////////G/wDt/8H8xP/B/MH/wfzE/8H80f/B/PH/AP/////p/9X/yv/F/8P/wf//////
///0/8H8xP/B/MH/wfzE/8H8xP/D/MT/wfzB/8L8wv/B/MX/wfz////////g/9D/yP/E/8L/////
////9P/B/MP/wfzD/8H8w//B/MP/wfzD/8H8w//C/MT/wfzE/8H8////////4P/Q/8j/xP/C/8H/
////////xf8A7v/B/MP/wfzD/8H8w//B/ML/wfzF/8H8wv/B/MX/wfzD/8H8////////4f/Q/8j/
xP/C/8H/////////xf8A7//B/ML/wfzD/8H8wv/B/MP/wfzF/8H8wv/B/MX/wfzC/8H87/8A////
/+n/1P/K/8X/w//B/////////8X/AO//wfzB/8H8xf/B/MH/wfzD/8H8xf/B/ML/wfzF/8H8wf/C
/PD/AP/////o/9T/yv/F/8P/wf/////////E/wDw/8H8wf/B/MX/wfzB/8H8w//B/MX/wfzC/8H8
xf/C/ML/wfzv/wD/////6P/U/8r/xf/D/8H/////////9f/B/MH/wfzF/8H8wf/B/MP/wfzF/8H8
wv/B/MX/wfzD/8H87/8A/////+j/1P/K/8X/w//B//////////b/wfzH/8H8xf/B/MP/wfzD/8H8
xf/B/MT/wfz////////g/9D/yP/E/8L/wf/////////2/8H8x//B/Mb/w/zE/8H8xf/B/MX/wfz/
///////g/9D/yP/E/8L/////////xP8A/////8P/AP/////o/9T/yv/F/8P/wf/////////E/wD/
////w//CAP/////o/9T/yv/F/8L/wf/////////D/8IA/////8T/AP/////o/9T/yv/F/8L/wf/B
//8A1QD//+z/ANj//wDVANf/AP//+f/rANUAywDFAMMAAMH/AP//0/8A/////8b/AP//0/8A1/8A
///5/wDq/9X/y//F/8P/AMH/AP//0/8A/////8b/AP//0/8A/////9L/AOr/1f/L/8X/w/8Awf8A
///T/wD//+z/ANj/AP//0/8A/////9L/AOr/1f/L/8X/w/8Awf8A///T/wD//+z/ANj/AP//0/8A
1/8A///5/wDq/9X/y//F/8P/AMH/AP//0/8A///s/wDY/wD//9P/ANf/AP//+f8A6v/V/8v/xf/D
/wDB/wD//9P/AP//7P8A2P8A///T/wDX/wD///n/AOr/1f/L/8X/w/8Awf8A///T/wD//+z/ANj/
AP//0/8A1/8A///5/wDq/9X/y//F/8P/AMH/AP//0/8A/////8b/AP//0/8A/////9L/AOr/1f/L
/8X/w/8Awf8Ayf/DAMX/wwDN/wDG/wDU/wDU/wD/////xv8Ayf/DAMX/wwDN/wDG/wDT/8MA0/8A
/////9L/AMn/wwDF/8MAzf8Axv8A0//DAMv/xf/D/wDB/wDK/8IAxf/CAM3/wgDa/8IA1P8A///s
/wDY/wDK/8IAxf/CAM3/wgDZ/wDD/wDS/wD/////0v8Ayv/CAMX/wgDN/8IA2f8Aw/8Ayv/F/8P/
AMH/AMr/AMH/AMP/AMH/AM7/ANv/ANT/AP//7P8A2P8Ayv8Awf8Aw/8Awf8Azv8A3f8A0v8A1/8A
///5/wDK/wDB/wDD/wDB/wDO/wDZ/8T/AMr/xf/D/wDB/wDK/wDB/wDD/wDB/wDD/8IAxP/DAML/
AMH/wgDD/wDD/wDB/8IAw//CAMj/ANT/AP//7P8A2P8Ayv8Awf8Aw/8Awf8Aw//CAMT/wwDC/wDB
/8IAw/8Aw/8Awf/CAMP/wgDK/wDS/wDX/wD///n/AMr/AMH/AMP/AMH/AMP/wgDE/8MAwv8Awf/C
AMP/AMP/AMH/wgDD/8IAyf8Ay//F/8P/AMH/AMr/AMH/AMP/AMH/AML/AML/AML/AML/AML/wgDC
/wDB/8IAwv/DAML/AMH/AML/AMf/ANT/AP//7P8A2P8Ayv8Awf8Aw/8Awf8Awv8Awv8Awv8Awv8A
wv/CAML/AMH/wgDC/8MAwv8Awf8Awv8AyP8A0/8A1/8A///5/wDK/wDB/wDD/wDB/wDC/wDC/wDC
/wDC/wDC/8IAwv8Awf/CAML/wwDC/wDB/wDC/wDH/8IAy//F/8P/AMH/AMr/AML/AMH/AML/AMP/
wwDC/wDF/wDD/wDC/wDD/wDD/wDB/8QAx/8A1P8A/////8b/AMr/AML/AMH/AML/AMP/wwDC/wDF
/wDD/wDC/wDD/wDD/wDB/8QAyP8A0/8A1/8A///5/wDK/wDC/wDB/wDC/wDD/8MAwv8Axf8Aw/8A
wv8Aw/8Aw/8Awf/EAMn/AMr/xf/D/wDB/wDK/wDC/wDB/wDC/wDC/wDC/wDC/wDF/wDD/wDC/wDD
/wDD/wDB/wDE/8MAw/8A1P8A/////8b/AMr/AML/AMH/AML/AML/AML/AML/AMX/AMP/AML/AMP/
AMP/AMH/AMT/wwDD/wDU/wD/////0v8Ayv8Awv8Awf8Awv8Awv8Awv8Awv8Axf8Aw/8Awv8Aw/8A
w/8Awf8AxP/DAMX/AMr/xf/D/wDB/wDK/wDC/wDB/wDC/wDC/wDC/wDC/wDC/wDC/wDD/wDC/wDD
/wDD/wDB/wDC/wDH/wDU/wD//+3/ANf/AMr/AML/AMH/AML/AML/AML/AML/AML/AML/AMP/AML/
AMP/AMP/AMH/AML/AMb/AML/ANL/AP/////S/wDK/wDC/wDB/wDC/wDC/wDC/wDC/wDC/wDC/wDD
/wDC/wDD/wDD/wDB/wDC/wDJ/wDK/8X/w/8Awf8Ayf/DAML/AML/wwDC/8QAwv/CAML/wwDB/8YA
wf/DAMH/wwDB/8IAx//DANP/AP//7f8A1/8Ayf/DAML/AML/wwDC/8QAwv/CAML/wwDB/8YAwf/D
AMH/wwDB/8IAxv/FANL/ANb/AP//+v8Ayf/DAML/AML/wwDC/8QAwv/CAML/wwDB/8YAwf/DAMH/
wwDB/8IAxv/EAMv/xf/D/wDB/wD//9P/AP//7f8A1/8A///T/wDW/wD///r/AOr/1f/L/8X/w/8A
wf8A///T/wD//+3/ANf/AP//0/8A1v8A///6/wDq/9X/y//F/8P/AMH/AP//0/8A///t/8IA1v8A
///T/wDW/wD///r/AOr/1f/L/8X/w/8Awf8A///T/wD/////xv8A///T/wDV/wD///v/AOr/1f/L
/8X/w/8Awf8A///T/wD/////xv8A///T/wD/////0v8A6v/V/8v/xf/D/wDB/wD//9P/AP//7v8A
1v8A///T/wD/////0v8A6v/V/8v/xf/D/wDB/wD//9P/AP//7/8A1f8A///T/wD/////0v8A6v/V
/8v/xf/D/wDB/wD//9P/AP//7/8A1f8A///T/wD/////0v8A6v/V/8v/xf/D/wDB/wD//9P/AP//
7/8A1f8A///T/wDU/wD///z/AOr/1f/L/8X/w/8Awf8A///T/wD/////xv8A///T/wDU/wD///z/
AOr/1f/L/8X/w/8Awf8A///T/wD/////xv8A///T/wD/////0v8A6v/V/8v/xf/D/wDB/wD//9P/
AP/////G/wD//9P/AP/////S/wDq/9X/y//F/8P/AMH/AP//0/8A///x/wDT/wD//9P/ANL/AP//
/v8A6v/V/8v/xf/D/wDB/wD//9P/AP//8f8A0/8A///T/wDS/wD///7/AOr/1f/L/8X/w/8Awf8A
///T/wD///H/ANP/AP//0/8A0v8A///+/wDq/9X/y//F/8P/AMH/AP//0/8A///y/wDS/wD//9P/
ANL/AP///v8A6v/V/8v/xf/D/wDB/wD//9P/AP/////G/wD//9P/AP/////S/wDq/9X/y//F/8P/
AMH//wDVAP/////G//8A1QD/////0v/rANUAywDFAMMAAOX/AP/////j/wDd/wD7/wDb/wD/////
5f8A2P/M/8b/w//C/+X/AP/////k/wDc/wD7/wDb/wD/////5f8A2P/M/8b/w//C/+X/AP/////k
/8IA2/8A+/8A2v8A/////+b/ANj/zP/G/8P/wv/l/wD/////5f8A2/8A+/8A2v8A/////+b/ANj/
zP/G/8P/wv/l/wD////////C/wD7/wD/////+f/I/wDY/8z/xv/D/8L/5f8A////////wv8A+/8A
//////n/yP8A2P/M/8b/w//C/+X/AP///////8L/APv/ANf/AP/////p/wDY/8z/xv/D/8L/5f8A
/////+f/ANn/APv/ANf/AP/////p/wDY/8z/xv/D/8L/5f8A/////+j/ANj/APv/ANb/wgD/////
6f8A2P/M/8b/w//C/+X/AP///////8L/APv/ANX/wgD/////6v8A2P/M/8b/w//C/+X/AP//////
/8L/APv/AP/////5/8j/ANj/zP/G/8P/wv/l/wD/////6v8A1v8A+/8A0/8A/////+3/ANj/zP/G
/8P/wv/l/wD/////6/8A1f8A+/8A0/8A/////+3/ANj/zP/G/8P/wv/l/wD/////7P8A1P8A+/8A
0v/CAP/////t/wDY/8z/xv/D/8L/5f8A/////+3/ANP/APv/ANH/wgD/////7v8A2P/M/8b/w//C
/+X/AP///////8L/APv/AP/////5/8j/ANj/zP/G/8P/wv/l/wD/////7/8A0f8A+/8Az/8A////
//H/ANj/zP/G/8P/wv/l/wD////////C/wD7/wDP/wD/////8f8A2P/M/8b/w//C/+X/AP/////x
/wDP/wD7/wDO/wD/////8v8A2P/M/8b/w//C/+X/AP///////8L/APv/AMz/wgD/////8v/B/wDY
/8z/xv/D/8L/5f8A//////T/AMz/APv/AP/////5/8j/ANj/zP/G/8P/wv/l/wD//8j/wwDB/wDO
/wDL/wD//8z/AMz/APv/AMr/AO3/yADH/wD///X/w/8A2P/M/8b/w//C/+X/AP//x/8Aw//CANn/
wgD//83/wgDK/wD7/wDJ/8IA7/8AxP8Axv/CAP//9f/D/wDY/8z/xv/D/8L/5f8A///G/wDF/wDa
/wD//87/wgDJ/wD7/wDH/8MA8P8AyP8Aw/8A4/8A///U/wDY/8z/xv/D/8L/5f8A///G/wDg/wD/
/9H/AMf/APv/APr/AMj/AMP/AOP/AP//1P8A2P/M/8b/w//C/+X/AP//x//CAMf/wwDD/wDB/8IA
wf8Axf/DAMP/AP//0f/DAMX/APv/APr/AMP/AMP/xADB/wDB/8IAxf/DAMP/AMH/wgDC/wDB/8IA
xf/DAML/xAD//9L/ANj/zP/G/8P/wv/l/wD//8n/wgDE/wDD/wDB/8MAwv/CAMT/AMP/AML/AP//
0//CAMT/APv/AMP/wgD1/8UAxP8Aw//CAML/AMP/AMP/AMH/wwDD/8MAwv8Aw/8Aw/8Awv8A///U
/wDY/8z/xv/D/8L/5f8A///L/wDD/8UAwv8AxP8Ax//CAML/AP//2f8A+/8Awf/DAPb/AMP/AMT/
AMP/AMP/AMP/xQDC/wDF/wDD/wDD/8UAwv8A///U/wDY/8z/xv/D/8L/5f8A///M/wDC/wDG/wDE
/wDF/8IAwf8Awv8A///Z/wD7/wD6/wDI/wDD/wDD/wDD/wDG/wDF/wDD/wDD/wDG/wD//9T/ANj/
zP/G/8P/wv/l/wD//8b/AMX/AML/AMb/AMT/AMT/AMP/AML/AP//1//EAPn/wgD6/wDF/wDC/wDD
/wDD/wDD/wDG/wDF/wDD/wDD/wDG/wD//9T/ANj/zP/G/8P/wv/l/wD//8b/wgDD/wDD/wDD/wDC
/wDE/wDE/wDC/8IAwv8A///Z/wD3/8MAwf8A+v8AxP8Aw/8Awf8Awf8Aw/8Aw/8Aw/8Awv8Axf8A
w/8Aw/8Aw/8Awv8Awf8A///S/wDY/8z/xv/D/8L/5f8A///G/wDB/8MAxf/DAML/wwDC/8MAw//D
AMH/xQD//9j/AMP/APH/AMX/APj/yADD/8IAwf/DAMH/wwDD/8MAwv/DAMP/wwDB/8MAw//DAMP/
wgD//9P/ANj/zP/G/8P/wv/l/wD////////C/wDD/8UA6f/EAMb/AP/////5/8j/ANj/zP/G/8P/
wv/l/wD////////C/wDJ/wDx/wD/////+f/I/wDY/8z/xv/D/8L/5f8A////////wv8Ayv/EAN3/
xADM/wD/////+f/I/wDY/8z/xv/D/8L/5f8A////////wv8A0P/FAML/wgDH/8IAwv/EANP/AP//
///5/8j/ANj/zP/G/8P/wv/l//8A/wD/AMMA2v/CAML/wwDb//8A/wD6AMgA2f/M/8b/w//C////
////////////////7f/W/8v/xv/D/8H////////////////////t/9b/y//G/8P/wf//////////
/////////+3/1v/L/8b/w//B////////////////////7f/W/8v/xv/D/8H/////////////////
///t/9b/y//G/8P/wf///////////////////+3/1v/L/8b/w//B////////////////////7f/W
/8v/xv/D/8H////////////////////t/9b/y//G/8P/wf///////////////////+3/1v/L/8b/
w//B////////////////////7f/W/8v/xv/D/8H////////////////////t/9b/y//G/8P/wf//
/////////////////+3/1v/L/8b/w//B////////////////////7f/W/8v/xv/D/8H/////////
///////////t/9b/y//G/8P/wf///////////////////+3/1v/L/8b/w//B////////////////
////7f/W/8v/xv/D/8H////////////////////t/9b/y//G/8P/wf///////////////////+3/
1v/L/8b/w//B////////////////////7f/W/8v/xv/D/8H////////////////////t/9b/y//G
/8P/wf///////////////////+3/1v/L/8b/w//B////////////////////7f/W/8v/xv/D/8H/
///////////////////t/9b/y//G/8P/wf8MAAAAgAAAAIAAgIAAAACAgACAAICAwMDAwNzApsrw
QCAAYCAAgCAAoCAAwCAA4CAAAEAAIEAAQEAAYEAAgEAAoEAAwEAA4EAAAGAAIGAAQGAAYGAAgGAA
oGAAwGAA4GAAAIAAIIAAQIAAYIAAgIAAoIAAwIAA4IAAAKAAIKAAQKAAYKAAgKAAoKAAwKAA4KAA
AMAAIMAAQMAAYMAAgMAAoMAAwMAA4MAAAOAAIOAAQOAAYOAAgOAAoOAAwOAA4OAAAABAIABAQABA
YABAgABAoABAwABA4ABAACBAICBAQCBAYCBAgCBAoCBAwCBA4CBAAEBAIEBAQEBAYEBAgEBAoEBA
wEBA4EBAAGBAIGBAQGBAYGBAgGBAoGBAwGBA4GBAAIBAIIBAQIBAYIBAgIBAoIBAwIBA4IBAAKBA
IKBAQKBAYKBAgKBAoKBAwKBA4KBAAMBAIMBAQMBAYMBAgMBAoMBAwMBA4MBAAOBAIOBAQOBAYOBA
gOBAoOBAwOBA4OBAAACAIACAQACAYACAgACAoACAwACA4ACAACCAICCAQCCAYCCAgCCAoCCAwCCA
4CCAAECAIECAQECAYECAgECAoECAwECA4ECAAGCAIGCAQGCAYGCAgGCAoGCAwGCA4GCAAICAIICA
QICAYICAgICAoICAwICA4ICAAKCAIKCAQKCAYKCAgKCAoKCAwKCA4KCAAMCAIMCAQMCAYMCAgMCA
oMCAwMCA4MCAAOCAIOCAQOCAYOCAgOCAoOCAwOCA4OCAAADAIADAQADAYADAgADAoADAwADA4ADA
ACDAICDAQCDAYCDAgCDAoCDAwCDA4CDAAEDAIEDAQEDAYEDAgEDAoEDAwEDA4EDAAGDAIGDAQGDA
YGDAgGDAoGDAwGDA4GDAAIDAIIDAQIDAYIDAgIDAoIDAwIDA4IDAAKDAIKDAQKDAYKDAgKDAoKDA
wKDA4KDAAMDAIMDAQMDAYMDAgMDAoMDA//vwoKCkgICA/wAAAP8A//8AAAD//wD/AP//////

--0__=65256BC6001A4E248f9e8a93df938690918c65256BC6001A4E24--
