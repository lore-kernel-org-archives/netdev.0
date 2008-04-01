From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: strange output by iproute
Date: Tue, 1 Apr 2008 15:29:27 +0300
Message-ID: <20080401122720.M40183@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:57482 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbYDAM3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 08:29:41 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 88F89BD0BE
	for <netdev@vger.kernel.org>; Tue,  1 Apr 2008 15:29:27 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just compiled git of iproute2 5 days ago and got now very strange result once.
It is appearing sometimes, and it is very strange.


---- cut here ----
Kup /config # tc -s class show dev ifb0
class htb 1:33 parent 1:10 leaf 33: prio 0 rate 1000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 25138646821 bytes 136712003 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1122Kbit 834pps backlog 0b 0p requeues 0
 lended: 94780537 borrowed: 41931466 giants: 0
 tokens: -1960 ctokens: 400

class htb 1:11 parent 1:10 leaf 11: prio 0 rate 768000bit ceil 768000bit burst
1599b cburst 1599b
 Sent 5233133634 bytes 70274124 pkt (dropped 999541, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 70274124 borrowed: 0 giants: 0
 tokens: 15625 ctokens: 15625

class htb 1:32 parent 1:10 leaf 32: prio 0 rate 4000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 36468622600 bytes 220131699 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1643Kbit 1160pps backlog 0b 0p requeues 0
 lended: 189709817 borrowed: 30421882 giants: 0
 tokens: 2955 ctokens: 398

class htb 1:10 root rate 30000Kbit ceil 30000Kbit burst 1593b cburst 1593b
 Sent 378362330304 bytes 1853507190 pkt (dropped 0, overlimits 0 requeues 0)
 rate 21082Kbit 11973pps backlog 0b 0p requeues 0
 lended: 965728892 borrowed: 0 giants: 0
 tokens: -417 ctokens: -417

class htb 1:31 parent 1:10 leaf 31: prio 1 rate 400000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 40258027049 bytes 161274970 pkt (dropped 148898, overlimits 0 requeues 0)
 rate 2055Kbit 1031pps backlog 0b 0p requeues 0
 lended: 31066691 borrowed: 130208279 giants: 0
 tokens: -32370 ctokens: 381

class htb 1:20 parent 1:10 leaf 20: prio 0 rate 7500Kbit ceil 30000Kbit burst
1598b cburst 1593b
 Sent 69564875811 bytes 91531364 pkt (dropped 0, overlimits 0 requeues 0)
 rate 4478Kbit 640pps backlog 0b 0p requeues 0
 lended: 76105073 borrowed: 15426291 giants: 0
 tokens: -1582 ctokens: -362

class htb 1:30 parent 1:10 leaf 30: prio 0 rate 500000bit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 8136967446 bytes 66901150 pkt (dropped 2490, overlimits 0 requeues 0)
 rate 470384bit 363pps backlog 0b 0p requeues 0
 lended: 59208713 borrowed: 7692437 giants: 0
 tokens: 20578 ctokens: 392

class htb 1:51 parent 1:10 leaf 51: prio 7 rate 50000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 7301267802 bytes 36807266 pkt (dropped 749890, overlimits 0 requeues 0)
 rate 336608bit 261pps backlog 0b 4p requeues 0
 lended: 6044453 borrowed: 30762809 giants: 0
 tokens: -119684 ctokens: 398

class htb 1:40 parent 1:10 leaf 40: prio 1 rate 1000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 58385697458 bytes 460878888 pkt (dropped 1464931, overlimits 0 requeues 0)
 rate 2461Kbit 2515pps backlog 0b 0p requeues 0
 lended: 161530940 borrowed: 299347948 giants: 0
 tokens: -7341 ctokens: 385

class htb 1:15 parent 1:10 leaf 15: prio 0 rate 1000Kbit ceil 2000Kbit burst
1600b cburst 1600b
 Sent 12618875557 bytes 168361294 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1215Kbit 2034pps backlog 0b 0p requeues 0
 lended: 144203923 borrowed: 24157371 giants: 0
 tokens: -3652 ctokens: 5218

class htb 1:50 parent 1:10 leaf 50: prio 6 rate 450000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 108720804529 bytes 420135428 pkt (dropped 13176755, overlimits 0 requeues 0)
 rate 7059Kbit 3054pps backlog 0b 24p requeues 0
 lended: 37965993 borrowed: 382169411 giants: 0
 tokens: -27201 ctokens: 28

class htb 1:60 parent 1:10 leaf 60: prio 0 rate 500000bit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 6968064694 bytes 20499022 pkt (dropped 0, overlimits 0 requeues 0)
 rate 240448bit 81pps backlog 0b 0p requeues 0
 lended: 16888024 borrowed: 3610998 giants: 0
 tokens: -34763 ctokens: 185

class htb 1:34 parent 1:10 leaf 34: prio 0 rate 100000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 832 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 10 borrowed: 0 giants: 0
 tokens: 85027 ctokens: 394

class sfq 50:81 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 12194

class sfq 50:98 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 1514

class sfq 50:9f parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 3028

class sfq 50:10e parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 4p requeues 0
 allot 12160

class sfq 50:124 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 1514

class sfq 50:134 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 13566

class sfq 50:14a parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4542

class sfq 50:14e parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot -27746

class sfq 50:194 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 1454

class sfq 50:1ba parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4482

class sfq 50:1c4 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 25534

class sfq 50:1f4 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4482

class sfq 50:276 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 8958

class sfq 50:2bc parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 10546

class sfq 50:30e parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4476

class sfq 50:346 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 17947

class sfq 50:36b parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 16462

class sfq 50:3b4 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 31068

class sfq 50:3c5 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 7570

class sfq 50:3c7 parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot -30780

class sfq 50:3fa parent 50:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4482

class sfq 51:3f parent 51:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 4542

class sfq 51:ce parent 51:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 1514

class sfq 51:260 parent 51:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 5990

class sfq 51:2fb parent 51:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 1514

------- EOF -----
I try once more and got as expected.


Kup /config # tc -s class show dev ifb0
class htb 1:33 parent 1:10 leaf 33: prio 0 rate 1000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 25140191221 bytes 136719932 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1221Kbit 839pps backlog 0b 0p requeues 0
 lended: 94786253 borrowed: 41933679 giants: 0
 tokens: -1874 ctokens: 335

class htb 1:11 parent 1:10 leaf 11: prio 0 rate 768000bit ceil 768000bit burst
1599b cburst 1599b
 Sent 5233133634 bytes 70274124 pkt (dropped 999541, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 70274124 borrowed: 0 giants: 0
 tokens: 15625 ctokens: 15625

class htb 1:32 parent 1:10 leaf 32: prio 0 rate 4000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 36470520510 bytes 220142670 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1619Kbit 1152pps backlog 0b 0p requeues 0
 lended: 189720512 borrowed: 30422158 giants: 0
 tokens: 3000 ctokens: 400

class htb 1:10 root rate 30000Kbit ceil 30000Kbit burst 1593b cburst 1593b
 Sent 378386632833 bytes 1853620380 pkt (dropped 0, overlimits 0 requeues 0)
 rate 20890Kbit 12010pps backlog 0b 0p requeues 0
 lended: 965788568 borrowed: 0 giants: 0
 tokens: -250 ctokens: -250

class htb 1:31 parent 1:10 leaf 31: prio 1 rate 400000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 40260035957 bytes 161283523 pkt (dropped 148898, overlimits 0 requeues 0)
 rate 1873Kbit 958pps backlog 0b 0p requeues 0
 lended: 31068844 borrowed: 130214679 giants: 0
 tokens: -32031 ctokens: 2

class htb 1:20 parent 1:10 leaf 20: prio 0 rate 7500Kbit ceil 30000Kbit burst
1598b cburst 1593b
 Sent 69570128471 bytes 91537406 pkt (dropped 0, overlimits 0 requeues 0)
 rate 4480Kbit 638pps backlog 0b 0p requeues 0
 lended: 76110030 borrowed: 15427376 giants: 0
 tokens: 1150 ctokens: 288

class htb 1:30 parent 1:10 leaf 30: prio 0 rate 500000bit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 8137666683 bytes 66904590 pkt (dropped 2490, overlimits 0 requeues 0)
 rate 537488bit 363pps backlog 0b 0p requeues 0
 lended: 59211218 borrowed: 7693372 giants: 0
 tokens: 2263 ctokens: 400

class htb 1:51 parent 1:10 leaf 51: prio 7 rate 50000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 7301725680 bytes 36809801 pkt (dropped 749890, overlimits 0 requeues 0)
 rate 366480bit 269pps backlog 0b 0p requeues 0
 lended: 6044904 borrowed: 30764897 giants: 0
 tokens: -149986 ctokens: 400

class htb 1:40 parent 1:10 leaf 40: prio 1 rate 1000Kbit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 58388528262 bytes 460901949 pkt (dropped 1464931, overlimits 0 requeues 0)
 rate 2411Kbit 2469pps backlog 0b 0p requeues 0
 lended: 161540358 borrowed: 299361591 giants: 0
 tokens: -2948 ctokens: 371

class htb 1:15 parent 1:10 leaf 15: prio 0 rate 1000Kbit ceil 2000Kbit burst
1600b cburst 1600b
 Sent 12620424082 bytes 168382085 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1270Kbit 2129pps backlog 0b 0p requeues 0
 lended: 144218688 borrowed: 24163397 giants: 0
 tokens: -8812 ctokens: 4126

class htb 1:50 parent 1:10 leaf 50: prio 6 rate 450000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 108728566808 bytes 420164374 pkt (dropped 13176755, overlimits 0 requeues 0)
 rate 6869Kbit 3105pps backlog 0b 0p requeues 0
 lended: 37967958 borrowed: 382196416 giants: 0
 tokens: -28143 ctokens: 28

class htb 1:60 parent 1:10 leaf 60: prio 0 rate 500000bit ceil 30000Kbit burst
1600b cburst 1593b
 Sent 6968355396 bytes 20499916 pkt (dropped 0, overlimits 0 requeues 0)
 rate 242720bit 87pps backlog 0b 0p requeues 0
 lended: 16888913 borrowed: 3611003 giants: 0
 tokens: 23500 ctokens: 392

class htb 1:34 parent 1:10 leaf 34: prio 0 rate 100000bit ceil 30000Kbit burst
1599b cburst 1593b
 Sent 832 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 10 borrowed: 0 giants: 0
 tokens: 85027 ctokens: 394

Here is i check more:
Kup /config # tc -s class show dev ifb0|grep sfq
class sfq 40:1f parent 40:
class sfq 40:9c parent 40:
class sfq 40:b4 parent 40:
class sfq 40:1be parent 40:
class sfq 40:251 parent 40:
class sfq 40:276 parent 40:
class sfq 40:2f6 parent 40:
class sfq 40:345 parent 40:
class sfq 50:31 parent 50:
class sfq 50:81 parent 50:
class sfq 50:ab parent 50:
class sfq 50:d6 parent 50:
class sfq 50:134 parent 50:
class sfq 50:158 parent 50:
class sfq 50:1e2 parent 50:
class sfq 50:1fc parent 50:
class sfq 50:247 parent 50:
class sfq 50:282 parent 50:
class sfq 50:2a2 parent 50:
class sfq 50:2e3 parent 50:
class sfq 50:2f4 parent 50:
class sfq 50:305 parent 50:
class sfq 50:337 parent 50:
class sfq 50:360 parent 50:
class sfq 50:400 parent 50:
class sfq 51:cf parent 51:
class sfq 51:151 parent 51:
class sfq 51:27f parent 51:
Kup /config # tc -s class show dev ifb0|grep sfq
Kup /config # tc -s class show dev ifb0|grep sfq
Kup /config # tc -s class show dev ifb0|grep sfq
class sfq 31:2e4 parent 31:
class sfq 40:1c3 parent 40:
class sfq 40:240 parent 40:
class sfq 40:2ce parent 40:
class sfq 40:30c parent 40:
class sfq 50:51 parent 50:
class sfq 50:d9 parent 50:
class sfq 50:e9 parent 50:
class sfq 50:151 parent 50:
class sfq 50:1fa parent 50:
class sfq 50:258 parent 50:
class sfq 50:2a2 parent 50:
class sfq 50:2ee parent 50:



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

