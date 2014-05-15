From: =?UTF-8?B?44Kr44Kq44CA44Of44Oz44CA44OS44Kn44OD44OX?=
	<cm-hiep@jinso.co.jp>
Subject: Ethernet bug at Upstream-v3.15-rcx on Lager.
Date: Thu, 15 May 2014 15:28:24 +0900
Message-ID: <53745E88.7040108@jinso.co.jp>
Reply-To: cm-hiep@jinso.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qecsay241.secure.ne.jp ([158.199.161.241]:39940 "HELO
	m119.secure.ne.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1753886AbaEOGfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 02:35:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei

I am Hiep from JINZAI SOLUTION (a Japanese Company).
Now, I am testing a upstream-v3.15-rc2 on Lager for Renesas RSO.
I found a problem about Ethernet Driver so I would like to report to yo=
u.
The problem is losing data when sending data by UDP:

     - From Lager board to PC:
     BANDWIDTH from 10M to 70M are good,  but they suddenly  down 51.2=20
Mbits/sec at 80M
     and 57.8 Mbits/sec at 90 M and 64.2 Mbits/sec at 100M.

     - From PC to Lager board:
    Some time when the message of "sh-eth r8a7790-ether eth0: Receive=20
=46IFO Overflow" occurs,
    some of datagrams will be lost as the logs show below:
     =E3=80=8C$ iperf -c 172.16.1.36 -u -b 90M
     .....
     [  3] Server Report:
     [  3]  0.0-10.0 sec   108 MBytes  90.4 Mbits/sec   0.000 ms=20
36/76923 (0.047%)
     .....
     # iperf -s -u
     [ ID] Interval       Transfer     Bandwidth        Jitter=20
Lost/Total Datagrams
     sh-eth r8a7790-ether eth0: Receive FIFO Overflow
     [  3]  0.0-10.0 sec   108 MBytes  90.4 Mbits/sec   0.001 ms=20
36/76923 (0.047%)

Please review it when you have time.

Bests Regards,
Cao Minh Hiep.
