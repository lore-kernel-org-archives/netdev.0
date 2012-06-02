From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Network hangs on current git kernel
Date: Sat, 2 Jun 2012 10:25:03 +0200
Message-ID: <20120602082503.GC329@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:43270 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966541Ab2FBIbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 04:31:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running the latest git kernel 3.4.0-09820-g86c47b7 and see periodic
network "hangs" on my machine.

These hangs mostly occur when I read nntp news articles. Every once in a
while the nntp client seems to take forever to fetch an article. During
these hangs I see packet losses:

 % ping heise.de
PING heise.de (193.99.144.80) 56(84) bytes of data.
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=2 ttl=246 time=22.2 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=4 ttl=246 time=22.3 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=8 ttl=246 time=21.9 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=12 ttl=246 time=23.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=15 ttl=246 time=22.5 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=19 ttl=246 time=22.9 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=21 ttl=246 time=21.6 ms <== Hang stops here
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=22 ttl=246 time=23.2 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=23 ttl=246 time=23.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=24 ttl=246 time=22.9 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=25 ttl=246 time=22.9 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=26 ttl=246 time=22.5 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=27 ttl=246 time=22.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=28 ttl=246 time=22.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=29 ttl=246 time=22.0 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=30 ttl=246 time=22.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=31 ttl=246 time=22.0 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=32 ttl=246 time=22.0 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=33 ttl=246 time=22.0 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=34 ttl=246 time=21.8 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=35 ttl=246 time=23.1 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=36 ttl=246 time=22.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=37 ttl=246 time=23.2 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=38 ttl=246 time=22.3 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=39 ttl=246 time=32.2 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=40 ttl=246 time=22.5 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=41 ttl=246 time=22.6 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=42 ttl=246 time=23.7 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=43 ttl=246 time=22.7 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=44 ttl=246 time=27.4 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=45 ttl=246 time=22.2 ms
64 bytes from redirector.heise.de (193.99.144.80): icmp_req=46 ttl=246 time=22.5 ms
^C
--- heise.de ping statistics ---
46 packets transmitted, 32 received, 30% packet loss, time 45101ms
rtt min/avg/max/mdev = 21.613/23.021/32.210/1.924 ms

Sorry, if this all sounds somewhat vague. I will try to record a sysrq-w dump
in the future.

-- 
Markus
