From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!     2.6.28
Date: Thu, 8 Jan 2009 20:32:16 +0200
Message-ID: <200901082032.16859.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: mysql.jorge@decimal.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:32814 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbZAHScO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:32:14 -0500
In-Reply-To: <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I disable tso/gso and others. No difference at all. Here is actual output, 
after running it for 1-2 minutes.

Cisco
  30 second output rate 59600000 bits/sec, 32978 packets/sec
Linux

class htb 1:33 parent 1:10 leaf 33: prio 0 rate 1000Kbit ceil 57000Kbit burst 
2849b cburst 72838b
 Sent 63746261 bytes 492929 pkt (dropped 0, overlimits 0 requeues 0)
 rate 61200bit 48pps backlog 0b 0p requeues 0
 lended: 491208 borrowed: 1721 giants: 0
 tokens: 21453 ctokens: 9971

class htb 1:32 parent 1:10 leaf 32: prio 0 rate 4000Kbit ceil 57000Kbit burst 
6599b cburst 72838b
 Sent 7976915758 bytes 45773720 pkt (dropped 0, overlimits 0 requeues 0)
 rate 7242Kbit 5300pps backlog 0b 0p requeues 0
 lended: 28141768 borrowed: 17631952 giants: 0
 tokens: -1245 ctokens: 9972

class htb 1:10 root rate 57000Kbit ceil 57000Kbit burst 72838b cburst 72838b
 Sent 75203300117 bytes 328680653 pkt (dropped 0, overlimits 0 requeues 0)
 rate 58008Kbit 32891pps backlog 0b 0p requeues 0
 lended: 223536594 borrowed: 0 giants: 0
 tokens: 165 ctokens: 165

class htb 1:31 parent 1:10 leaf 31: prio 1 rate 400000bit ceil 57000Kbit burst 
2099b cburst 72838b
 Sent 9434582792 bytes 34978695 pkt (dropped 15721, overlimits 0 requeues 0)
 rate 7667Kbit 3561pps backlog 0b 0p requeues 0
 lended: 1739830 borrowed: 33238865 giants: 0
 tokens: -279 ctokens: 9973

class htb 1:30 parent 1:10 leaf 30: prio 0 rate 500000bit ceil 57000Kbit burst 
2224b cburst 72838b
 Sent 2197649866 bytes 13793068 pkt (dropped 0, overlimits 0 requeues 0)
 rate 2217Kbit 1270pps backlog 0b 0p requeues 0
 lended: 4124325 borrowed: 9668743 giants: 0
 tokens: -1671 ctokens: 9973

class htb 1:15 parent 1:10 leaf 15: prio 0 rate 1000Kbit ceil 2000Kbit burst 
2849b cburst 4Kb
 Sent 813164294 bytes 10048814 pkt (dropped 0, overlimits 0 requeues 0)
 rate 798896bit 1100pps backlog 0b 0p requeues 0
 lended: 10029689 borrowed: 19125 giants: 0
 tokens: 21703 ctokens: 15734

class htb 1:51 parent 1:10 leaf 51: prio 7 rate 50000bit ceil 57000Kbit burst 
1661b cburst 72838b
 Sent 706714762 bytes 3749931 pkt (dropped 11334, overlimits 0 requeues 0)
 rate 496816bit 379pps backlog 0b 75p requeues 0
 lended: 333427 borrowed: 3416429 giants: 0
 tokens: -11240 ctokens: 9975

class htb 1:14 parent 1:10 leaf 14: prio 0 rate 7000Kbit ceil 9000Kbit burst 
10348b cburst 12848b
 Sent 8537716658 bytes 48711461 pkt (dropped 24071, overlimits 0 requeues 0)
 rate 6797Kbit 4708pps backlog 0b 0p requeues 0
 lended: 43171840 borrowed: 5539621 giants: 0
 tokens: 1524 ctokens: 9829

class htb 1:50 parent 1:10 leaf 50: prio 6 rate 450000bit ceil 57000Kbit burst 
2161b cburst 72838b
 Sent 17728543906 bytes 59672028 pkt (dropped 2279236, overlimits 0 requeues 
0)
 rate 8312Kbit 4094pps backlog 0b 127p requeues 0
 lended: 1870954 borrowed: 57800947 giants: 0
 tokens: -26247 ctokens: 9777

class htb 1:34 parent 1:10 leaf 34: prio 0 rate 100000bit ceil 57000Kbit burst 
1724b cburst 72838b
 Sent 766 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 lended: 10 borrowed: 0 giants: 0
 tokens: 93732 ctokens: 9972

class htb 1:20 parent 1:10 leaf 20: prio 0 rate 7500Kbit ceil 57000Kbit burst 
10973b cburst 72838b
 Sent 13347788718 bytes 9570719 pkt (dropped 47, overlimits 0 requeues 0)
 rate 11340Kbit 998pps backlog 0b 0p requeues 0
 lended: 6344649 borrowed: 3226070 giants: 0
 tokens: -853 ctokens: 9614

class htb 1:40 parent 1:10 leaf 40: prio 1 rate 1000Kbit ceil 57000Kbit burst 
2849b cburst 72838b
 Sent 14456405280 bytes 101216398 pkt (dropped 468764, overlimits 0 requeues 
0)
 rate 13221Kbit 11365pps backlog 0b 33p requeues 0
 lended: 8223510 borrowed: 92992855 giants: 0
 tokens: -761 ctokens: 9964

class htb 1:60 parent 1:10 leaf 60: prio 0 rate 500000bit ceil 57000Kbit burst 
2224b cburst 72838b
 Sent 51868158 bytes 673116 pkt (dropped 0, overlimits 0 requeues 0)
 rate 47024bit 81pps backlog 0b 0p requeues 0
 lended: 672849 borrowed: 267 giants: 0
 tokens: 33265 ctokens: 9972

class sfq 40:3 parent 40:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot -20340

class sfq 40:72 parent 40:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot 12112

class sfq 40:98 parent 40:
 (dropped 0, overlimits 0 requeues 0)
 backlog 0b 1p requeues 0
 allot -4228

..... others is SFQ





On Thursday 08 January 2009 19:27:31 mysql.jorge@decimal.pt wrote:
> I asume there's some issue with the NIC Driver os the kernel modules with
> the 1000Mbit NIC's? am i correct?
>
> > An active connection when running this commands:
> > (now it seams to work, the 200Kbit i defined, are gaving me 22.5/23Kbyte
> > /sec)
> >

