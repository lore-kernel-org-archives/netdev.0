From: "Igor Serikov" <igor@veo.com>
Subject: kernel 2.4 TCP stack problem (uClinux, ARM7 platform)
Date: Mon, 8 Dec 2003 22:09:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3A10AC3F9A35D44BBF397F889FAF5FBF096191@server_2.veo.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <tfischer@velocitus.net>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    Hello,

  See the short log bellow (sequence numbers are relative). Sending side
is uClinux based on kernel-v2.4 ARM 7 platform, receiving side is Mac OS
X
(changing receiving side to Windows XP produce the same results).
Another important factors are: Fast Ethernet network and long time 
connection (the trouble usually happens within 1 hour). The data
source is network camera that sends continues MIME stream.

At certain moment the TCP Linux' stack starts sending empty TCP
packets instead of sending the data. The connection does not die.

 Thanks,
   Igor.


12:36:08.465357 camera > PC: . 294537538:294538986(1448) ack 1 win 5792
<nop,nop,timestamp 8002273 2507> (DF)
12:36:08.466761 camera > PC: . 294538986:294540434(1448) ack 1 win 5792
<nop,nop,timestamp 8002273 2507> (DF)
12:36:08.466913 PC > camera: . ack 294540434 win 33304
<nop,nop,timestamp 2507 8002273> (DF)
12:36:08.468852 camera > PC: . 294540434:294541882(1448) ack 1 win 5792
<nop,nop,timestamp 8002273 2507> (DF)
12:36:08.470251 camera > PC: . 294541882:294543330(1448) ack 1 win 5792
<nop,nop,timestamp 8002273 2507> (DF)
12:36:08.470406 PC > camera: . ack 294543330 win 33304
<nop,nop,timestamp 2507 8002273> (DF)
12:36:08.473466 camera > PC: . 294543330:294544778(1448) ack 1 win 5792
<nop,nop,timestamp 8002274 2507> (DF)
12:36:08.474997 camera > PC: . 294544778:294546226(1448) ack 1 win 5792
<nop,nop,timestamp 8002274 2507> (DF)
12:36:08.475164 PC > camera: . ack 294546226 win 33304
<nop,nop,timestamp 2507 8002274> (DF)
12:36:08.476912 camera > PC: P 294546226:294546309(83) ack 1 win 5792
<nop,nop,timestamp 8002274 2507> (DF)
12:36:08.495083 camera > PC: . 294546309:294547757(1448) ack 1 win 5792
<nop,nop,timestamp 8002276 2507> (DF)
12:36:08.496490 camera > PC: . 294547757:294549205(1448) ack 1 win 5792
<nop,nop,timestamp 8002276 2507> (DF)
12:36:08.496659 PC > camera: . ack 294549205 win 33304
<nop,nop,timestamp 2507 8002274> (DF)
12:36:08.498551 camera > PC: . 294549205:294550653(1448) ack 1 win 5792
<nop,nop,timestamp 8002276 2507> (DF)
12:36:08.499974 camera > PC: . 294550653:294552101(1448) ack 1 win 5792
<nop,nop,timestamp 8002276 2507> (DF)
12:36:08.500128 PC > camera: . ack 294552101 win 33304
<nop,nop,timestamp 2507 8002276> (DF)
12:36:08.502213 camera > PC: . 294552101:294553549(1448) ack 1 win 5792
<nop,nop,timestamp 8002276 2507> (DF)
12:36:08.504127 camera > PC: . 294553549:294554997(1448) ack 1 win 5792
<nop,nop,timestamp 8002277 2507> (DF)
12:36:08.504323 PC > camera: . ack 294554997 win 33304
<nop,nop,timestamp 2507 8002276> (DF)
12:36:08.506119 camera > PC: . 294554997:294556445(1448) ack 1 win 5792
<nop,nop,timestamp 8002277 2507> (DF)
12:36:08.507675 camera > PC: . 294556445:294557893(1448) ack 1 win 5792
<nop,nop,timestamp 8002277 2507> (DF)
12:36:08.508772 camera > PC: P 294557893:294557920(27) ack 1 win 5792
<nop,nop,timestamp 8002277 2507> (DF)
12:36:08.510448 PC > camera: . ack 294557920 win 33304
<nop,nop,timestamp 2507 8002277> (DF)
12:36:08.525111 camera > PC: P 294557920:294558018(98) ack 1 win 5792
<nop,nop,timestamp 8002279 2507> (DF)
12:36:08.529038 camera > PC: . 294558018:294559466(1448) ack 1 win 5792
<nop,nop,timestamp 8002279 2507> (DF)
12:36:08.530311 camera > PC: . 294559466:294560914(1448) ack 1 win 5792
<nop,nop,timestamp 8002279 2507> (DF)
12:36:08.530538 PC > camera: . ack 294560914 win 33304
<nop,nop,timestamp 2507 8002279> (DF)
12:36:08.532702 camera > PC: . 294560914:294562362(1448) ack 1 win 5792
<nop,nop,timestamp 8002279 2507> (DF)
12:36:08.534611 camera > PC: . 294562362:294563810(1448) ack 1 win 5792
<nop,nop,timestamp 8002280 2507> (DF)
12:36:08.534775 PC > camera: . ack 294563810 win 33304
<nop,nop,timestamp 2507 8002279> (DF)
12:36:08.536522 camera > PC: . 294563810:294565258(1448) ack 1 win 5792
<nop,nop,timestamp 8002280 2507> (DF)
12:36:08.537781 camera > PC: . 294565258:294566706(1448) ack 1 win 5792
<nop,nop,timestamp 8002280 2507> (DF)
12:36:08.537999 PC > camera: . ack 294566706 win 33304
<nop,nop,timestamp 2507 8002280> (DF)
12:36:08.539715 camera > PC: . 294566706:294568154(1448) ack 1 win 5792
<nop,nop,timestamp 8002280 2507> (DF)
12:36:08.541633 camera > PC: P 294568154:294569589(1435) ack 1 win 5792
<nop,nop,timestamp 8002280 2507> (DF)
12:36:08.594664 PC > camera: . ack 294569589 win 33304
<nop,nop,timestamp 2507 8002280> (DF)
12:36:08.842150 camera > PC: . ack 1 win 5792 <nop,nop,timestamp 8002311
2507> (DF)
12:36:08.842302 PC > camera: . ack 294569589 win 33304
<nop,nop,timestamp 2508 8002311> (DF)
12:36:09.092104 camera > PC: . ack 1 win 5792 <nop,nop,timestamp 8002336
2508> (DF)
12:36:09.092187 PC > camera: . ack 294569589 win 33304
<nop,nop,timestamp 2508 8002336> (DF)
12:36:09.342105 camera > PC: . ack 1 win 5792 <nop,nop,timestamp 8002361
2508> (DF)
