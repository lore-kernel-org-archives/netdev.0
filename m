From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: DoS by cat /proc/net/ip_conntrack ?
Date: Thu, 6 Mar 2008 15:43:23 +0200
Message-ID: <20080306134037.M70019@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:42882 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbYCFNnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 08:43:35 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 302FE408253
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 15:43:23 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again

On loaded router
net.netfilter.nf_conntrack_count = 415633
passing about 100-150 Mbps
network cards 3xe100, 1xe1000e

i tried to issue command cat /proc/net/ip_conntrack |grep 'something'

Router went dead for about 2 minutes, even i disconnect ssh session. 
Ping was looks like this:
64 bytes from dotfib (10.184.184.1): icmp_seq=15 ttl=61 time=4321 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=50 ttl=61 time=398 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=122 ttl=61 time=15.3 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=142 ttl=61 time=4452 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=180 ttl=61 time=850 ms
(system recovered)
64 bytes from dotfib (10.184.184.1): icmp_seq=182 ttl=61 time=0.681 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=183 ttl=61 time=0.936 ms
64 bytes from dotfib (10.184.184.1): icmp_seq=184 ttl=61 time=2.94 ms

I dont think it is normal, and such command taking a lot of system resources 
and cause whole system to hang.

Kernel 2.6.24.2

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

