From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: htb and UDP packages bigger than 1500
Date: Mon, 10 Dec 2007 18:10:50 +0100
Message-ID: <200712101810.50730.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.carme.maven.pl ([193.239.45.138]:34268 "EHLO
	main.carme.maven.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbXLJRiL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 12:38:11 -0500
Received: from chello089076027229.chello.pl ([89.76.27.229] helo=[192.168.0.124])
	by main.carme.maven.pl with esmtpa (Exim 4.67)
	(envelope-from <arekm@maven.pl>)
	id 1J1m9i-0005eb-0M
	for netdev@vger.kernel.org; Mon, 10 Dec 2007 18:10:58 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I noticed that HTB doesn't properly limit traffic if someone sends UDP=20
packages bigger than 1500.=20

Does HTB have some problems/known limits in this area?

There is other traffic in that class and when I drop udp packets bigger=
 than=20
1500 then remaining traffic is limited properly to correct value.

udp part of tcpdump log:
17:35:24.041364 IP 172.16.4.23.3185 > 80.51.230.58.9267: UDP, length 35
17:35:24.048834 IP 172.16.4.23.46073 > 83.53.197.205.50882: UDP, length=
 35
17:35:24.071234 IP 172.16.4.23.2904 > 81.38.28.69.26349: UDP, length 35
17:35:24.076924 IP 201.232.209.115.50750 > 172.16.4.23.57590: UDP, leng=
th 8251
17:35:24.140895 IP 90.242.120.252.11982 > 172.16.4.23.19111: UDP, lengt=
h 35
17:35:24.140976 IP 79.186.64.121.47130 > 172.16.4.23.19111: UDP, length=
 35
17:35:24.141039 IP 24.150.182.77.55984 > 172.16.4.23.41279: UDP, length=
 29
17:35:24.141120 IP 83.37.212.153.25153 > 172.16.4.23.32824: UDP, length=
 8251
17:35:24.154874 IP 172.16.4.23.19111 > 90.242.120.252.11982: UDP, lengt=
h 8251
17:35:24.210940 IP 83.8.18.150.28955 > 172.16.4.23.24825: UDP, length 8=
251
17:35:24.240382 IP 172.16.4.23.19111 > 79.186.64.121.47130: UDP, length=
 8251
17:35:24.272529 IP 83.19.224.219.32977 > 172.16.4.23.19111: UDP, length=
 35
17:35:24.307164 IP 85.219.10.150.18601 > 172.16.4.23.51986: UDP, length=
 8251
17:35:24.312335 IP 83.26.249.97.10137 > 172.16.4.23.9383: UDP, length 8=
251
17:35:24.404250 IP 83.19.224.11.1833 > 172.16.4.23.21258: UDP, length 8=
251
17:35:24.467562 IP 196.206.89.182.58764 > 172.16.4.23.19111: UDP, lengt=
h 35
17:35:24.560058 IP 172.16.4.23.50417 > 82.5.204.164.1024: UDP, length 2=
5
17:35:24.563842 IP 172.16.4.23.24825 > 83.8.18.150.28955: UDP, length 3=
5
17:35:24.567316 IP 172.16.4.23.59727 > 195.60.65.36.61323: UDP, length =
35
17:35:24.569976 IP 83.11.67.228.31949 > 172.16.4.23.56823: UDP, length =
8251
17:35:24.617104 IP 172.16.4.23.28945 > 76.11.24.115.13887: UDP, length =
29
17:35:24.619235 IP 172.16.4.23.21258 > 83.19.224.11.1833: UDP, length 3=
5
17:35:24.626488 IP 172.16.4.23.9383 > 83.26.249.97.10137: UDP, length 3=
5
17:35:24.640367 IP 172.16.4.23.47366 > 91.146.230.1.38928: UDP, length =
25
17:35:24.644314 IP 90.242.120.252.1955 > 172.16.4.23.19111: UDP, length=
 35
17:35:24.652024 IP 81.184.124.145.22454 > 172.16.4.23.57089: UDP, lengt=
h 8251

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
