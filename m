From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: HTB/HSFC shaping precision
Date: Mon, 19 Nov 2007 10:55:17 +0200
Message-ID: <20071119083849.M87605@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:47721 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbXKSJyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 04:54:05 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 7C389410170
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 10:55:17 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi 2 all again

This is not a bug report this time :-) 
Just it is very interesting question, about using Linux "shaping" technologies
in serious jobs.

What i realised few days ago, many ISP's set on their STM-1(155520000 bits/s)
links (over Cisco) packet buffer/queue 40 packets(for example).
It means 103680  pps with 1500 byte packets,  and if buffer is only 40
packets, it means it require at least 0.3ms scheduler precision? Otherwise i
can have buffer overflow and as result packetloss(what is much worse than
delay in most of situations).

What i am interested - to utilise such links nearby 100%. So anything not
precise will kill idea.
Thats important, cause price for links in my area is about $1000-$1500 Mbit/s,
and just 1% lost/not utilised on STM-1 is up to $2325/USD lost per month.
I have to count also overhead, LAN jitter, and etc.

As far as i test, on HFSC if i set dmax 1ms-10ms it works much better (i am
talking about precision) than HTB with quantum 1514 (it is over ethernet). 

Anybody have ideas what is the precision of bandwidth shaping in HFSC/HTB?

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

