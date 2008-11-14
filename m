From: Mohan Lal Jangir <mohanlal@samsung.com>
Subject: ipv6 route configuration
Date: Fri, 14 Nov 2008 15:08:07 +0530
Message-ID: <3E7B3A98D9974986B65CC4E3C9409B3C@samsung4qkw9nm>
Mime-Version: 1.0
Content-Type: text/plain; reply-type=original; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:47280 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbYKNJbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 04:31:41 -0500
Received: from epmmp2 (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KAB00D7KH4OMS@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 14 Nov 2008 18:31:36 +0900 (KST)
Received: from samsung4qkw9nm ([107.108.208.34])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0KAB00CL3H4RV1@mmp2.samsung.com> for netdev@vger.kernel.org;
 Fri, 14 Nov 2008 18:31:40 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[foo:/root] route -A inet6 add 2::/64 gw 2::1 dev eth5
SIOCADDRT: Invalid argument
[foo:/root] 

Could someone please tell why route addition tells invalid argument ?

Gateway 2::1 is reachable.

[foo:/root] ping6 2::1
PING 2::1(2::1) 56 data bytes
64 bytes from 2::1: icmp_seq=0 ttl=64 time=0.755 ms
64 bytes from 2::1: icmp_seq=1 ttl=64 time=0.395 ms
 
--- 2::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1012ms
rtt min/avg/max/mdev = 0.395/0.575/0.755/0.180 ms, pipe 2

Thanks
-Mohan
