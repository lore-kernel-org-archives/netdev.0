From: cranium2003 <cranium2003@yahoo.com>
Subject: who is eating hw header in packets?
Date: Sat, 21 May 2005 02:48:35 -0700 (PDT)
Message-ID: <20050521094835.79200.qmail@web33015.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
             I use ethereal to capture a packet. I
sent a ping request packet to hosta from hostB. On
hostA it will be captured and replyis generated and
packet sent to hostB. But it is captured as

Frame 2 (98 bytes on wire, 98 bytes captured)
    Arrival Time: May 21, 2005 10:37:57.360894000
    Time delta from previous packet: 0.000409000
seconds
    Time relative to first packet: 0.000409000 seconds
    Frame Number: 2
    Packet Length: 98 bytes
    Capture Length: 98 bytes
Ethernet II, Src: 00:00:40:01:bc:29, Dst:
45:00:00:54:3a:2b
    Destination: 45:00:00:54:3a:2b (45:00:00:54:3a:2b)
    Source: 00:00:40:01:bc:29 (Applicon_01:bc:29)
    Type: Unknown (0xc0a8)
Data (84 bytes)

0000  01 fa c0 a8 01 0a 00 00 82 68 0e 0f 00 01 2d c2 
 .........h....-.
0010  8e 42 c3 7f 05 00 08 09 0a 0b 0c 0d 0e 0f 10 11 
 .B..............
0020  12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 
 .............. !
0030  22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 
 "#$%&'()*+,-./01
0040  32 33 34 35 36 37 00 00 00 00 00 00 00 00 00 00 
 234567..........
0050  00 00 00 00                                     
 ....

         I want to ask which routine in linux kernel
is discarding packet? Because what i found is that the
first 14 bytes((src + dst) HW header + protocol type
field) 
 00 08 a1 43 61 f5 00 08 a1 43 62 91 08 00 bytes are
replaced with next all bytes and last 14 bytes are
filled with 0's.
regards,
cranium.



		
__________________________________ 
Yahoo! Mail Mobile 
Take Yahoo! Mail with you! Check email on your mobile phone. 
http://mobile.yahoo.com/learn/mail 
