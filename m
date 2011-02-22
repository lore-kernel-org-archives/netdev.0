From: denys@visp.net.lb
Subject: iproute, setting manually rtt
Date: Tue, 22 Feb 2011 17:42:49 +0200
Message-ID: <97d8915d050c34fb9499617f78305786@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58129 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab1BVPm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 10:42:59 -0500
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPA id C3EF7368652
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 17:42:49 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I try to set some time values in iproute, and confused by results. Here 
 is example:

 bytecruncher ~ # ip route del 1.1.1.1;ip route add 1.1.1.1 via 
 217.151.224.113 rtt 10ms                                                 
                                                     bytecruncher ~ # ip 
 route
 1.1.1.1 via 217.151.224.113 dev eth0  rtt 3363235ms

 bytecruncher ~ # ip route del 1.1.1.1;ip route add 1.1.1.1 via 
 217.151.224.113 rtt 10ms rto_min 10ms
 bytecruncher ~ # ip route
 1.1.1.1 via 217.151.224.113 dev eth0  rtt 3363235ms rto_min lock 
 14100654ms

 Details about system:
 bytecruncher ~ # uname -a
 Linux bytecruncher 2.6.37.1-insat #4 SMP Tue Feb 22 15:16:53 EET 2011 
 x86_64 Intel(R) Xeon(R) CPU X5680 @ 3.33GHz GenuineIntel GNU/Linux
 bytecruncher ~ # ip -V
 ip utility, iproute2-ss110107

 I guess there is something really wrong. Not sure if in iproute or 
 kernel side.
