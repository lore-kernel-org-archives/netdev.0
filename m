From: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
Subject: Re: IBM (Lenovo) T60: e1000 driver high latency
Date: Mon, 31 Jul 2006 17:51:26 +0200
Message-ID: <20060731155126.GH2576@cip.informatik.uni-erlangen.de>
References: <20060731093433.GF2576@cip.informatik.uni-erlangen.de> <44CE1C37.2090001@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:63999 "EHLO
	faui03.informatik.uni-erlangen.de") by vger.kernel.org with ESMTP
	id S1030206AbWGaPv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 11:51:28 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <44CE1C37.2090001@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Auke,

> > CONFIG_IRQBALANCE=y

thanks for the feedback. The behaviour improoved. In my first tests it
wasn't so good. But now it seems perfect:

(thinkpad) [~] ping 131.188.30.102
PING 131.188.30.102 (131.188.30.102) 56(84) bytes of data.
64 bytes from 131.188.30.102: icmp_seq=1 ttl=64 time=419 ms
64 bytes from 131.188.30.102: icmp_seq=2 ttl=64 time=0.264 ms
64 bytes from 131.188.30.102: icmp_seq=3 ttl=64 time=0.701 ms
64 bytes from 131.188.30.102: icmp_seq=4 ttl=64 time=0.630 ms
64 bytes from 131.188.30.102: icmp_seq=5 ttl=64 time=0.710 ms
64 bytes from 131.188.30.102: icmp_seq=6 ttl=64 time=0.638 ms
64 bytes from 131.188.30.102: icmp_seq=7 ttl=64 time=0.588 ms
64 bytes from 131.188.30.102: icmp_seq=8 ttl=64 time=0.517 ms
64 bytes from 131.188.30.102: icmp_seq=9 ttl=64 time=0.445 ms
64 bytes from 131.188.30.102: icmp_seq=10 ttl=64 time=0.374 ms

--- 131.188.30.102 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8996ms
rtt min/avg/max/mdev = 0.264/42.447/419.606/125.719 ms
(thinkpad) [~] ping 131.188.30.102
PING 131.188.30.102 (131.188.30.102) 56(84) bytes of data.
64 bytes from 131.188.30.102: icmp_seq=1 ttl=64 time=0.547 ms
64 bytes from 131.188.30.102: icmp_seq=2 ttl=64 time=0.502 ms
64 bytes from 131.188.30.102: icmp_seq=3 ttl=64 time=0.402 ms
64 bytes from 131.188.30.102: icmp_seq=4 ttl=64 time=0.329 ms

--- 131.188.30.102 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2998ms
rtt min/avg/max/mdev = 0.329/0.445/0.547/0.085 ms
(thinkpad) [~] ping 131.188.30.102
PING 131.188.30.102 (131.188.30.102) 56(84) bytes of data.
64 bytes from 131.188.30.102: icmp_seq=1 ttl=64 time=0.301 ms
64 bytes from 131.188.30.102: icmp_seq=2 ttl=64 time=0.753 ms
64 bytes from 131.188.30.102: icmp_seq=3 ttl=64 time=0.681 ms
64 bytes from 131.188.30.102: icmp_seq=4 ttl=64 time=0.609 ms
64 bytes from 131.188.30.102: icmp_seq=5 ttl=64 time=0.538 ms
64 bytes from 131.188.30.102: icmp_seq=6 ttl=64 time=0.466 ms
64 bytes from 131.188.30.102: icmp_seq=7 ttl=64 time=0.374 ms
64 bytes from 131.188.30.102: icmp_seq=8 ttl=64 time=0.308 ms

--- 131.188.30.102 ping statistics ---
8 packets transmitted, 8 received, 0% packet loss, time 6993ms
rtt min/avg/max/mdev = 0.301/0.503/0.753/0.161 ms
(thinkpad) [~] ping www.heise.de
PING www.heise.de (193.99.144.85) 56(84) bytes of data.
64 bytes from www.heise.de (193.99.144.85): icmp_seq=1 ttl=246 time=1019 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=2 ttl=246 time=15.8 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=3 ttl=246 time=1000 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=4 ttl=246 time=360 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=5 ttl=246 time=39.1 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=6 ttl=246 time=360 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=7 ttl=246 time=1000 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=8 ttl=246 time=360 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=9 ttl=246 time=360 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=10 ttl=246 time=360 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=11 ttl=246 time=1000 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=12 ttl=246 time=319 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=13 ttl=246 time=20.5 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=14 ttl=246 time=350 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=15 ttl=246 time=792 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=16 ttl=246 time=350 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=17 ttl=246 time=1000 ms

--- www.heise.de ping statistics ---
18 packets transmitted, 17 received, 5% packet loss, time 17013ms
rtt min/avg/max/mdev = 15.835/512.385/1019.753/360.201 ms, pipe 2
(thinkpad) [~] ping www.google.de
PING www.l.google.com (66.249.85.104) 56(84) bytes of data.
64 bytes from 66.249.85.104: icmp_seq=1 ttl=246 time=732 ms
64 bytes from 66.249.85.104: icmp_seq=2 ttl=246 time=999 ms
64 bytes from 66.249.85.104: icmp_seq=3 ttl=246 time=1000 ms
64 bytes from 66.249.85.104: icmp_seq=4 ttl=246 time=400 ms

--- www.l.google.com ping statistics ---
5 packets transmitted, 4 received, 20% packet loss, time 4388ms
rtt min/avg/max/mdev = 400.939/783.424/1000.436/246.402 ms, pipe 2
(thinkpad) [~] uname -a
Linux thinkpad 2.6.17.7 #3 SMP Mon Jul 31 17:44:21 CEST 2006 i686 GNU/Linux
(thinkpad) [~] date
Mon Jul 31 17:47:39 CEST 2006
(thinkpad) [~] ping www.google.de
PING www.l.google.com (66.249.85.99) 56(84) bytes of data.
64 bytes from 66.249.85.99: icmp_seq=1 ttl=246 time=13.3 ms
64 bytes from 66.249.85.99: icmp_seq=2 ttl=246 time=13.4 ms
64 bytes from 66.249.85.99: icmp_seq=3 ttl=246 time=13.4 ms
64 bytes from 66.249.85.99: icmp_seq=4 ttl=246 time=13.3 ms
64 bytes from 66.249.85.99: icmp_seq=5 ttl=246 time=13.2 ms
64 bytes from 66.249.85.99: icmp_seq=6 ttl=246 time=13.6 ms
64 bytes from 66.249.85.99: icmp_seq=7 ttl=246 time=13.6 ms
64 bytes from 66.249.85.99: icmp_seq=8 ttl=246 time=13.5 ms
64 bytes from 66.249.85.99: icmp_seq=9 ttl=246 time=13.4 ms
64 bytes from 66.249.85.99: icmp_seq=10 ttl=246 time=13.4 ms
64 bytes from 66.249.85.99: icmp_seq=11 ttl=246 time=13.3 ms

--- www.l.google.com ping statistics ---
11 packets transmitted, 11 received, 0% packet loss, time 10002ms
rtt min/avg/max/mdev = 13.287/13.451/13.689/0.188 ms
(thinkpad) [~] ping www.heise.de
PING www.heise.de (193.99.144.85) 56(84) bytes of data.
64 bytes from www.heise.de (193.99.144.85): icmp_seq=1 ttl=246 time=13.9 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=2 ttl=246 time=13.8 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=3 ttl=246 time=14.2 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=4 ttl=246 time=14.2 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=5 ttl=246 time=13.6 ms
64 bytes from www.heise.de (193.99.144.85): icmp_seq=6 ttl=246 time=13.5 ms

--- www.heise.de ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 4995ms
rtt min/avg/max/mdev = 13.561/13.906/14.279/0.274 ms

        Thomas
