From: "Kristian Evensen" <kristrev@simula.no>
Subject: Performance hit with IP-tunnels
Date: Mon, 22 Mar 2010 11:17:17 +0100
Message-ID: <000301cac9a8$dcd53750$967fa5f0$@no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-ppp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:57018 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab0CVKpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 06:45:30 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <kristrev@simula.no>)
	id 1NtekV-0007W8-64
	for netdev@vger.kernel.org; Mon, 22 Mar 2010 11:20:43 +0100
Content-Language: no
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am currently comparing different IP-tunneling protocols/implementations,
and have stumbled upon something I am not able to explain. Regardless of
which tunneling technology I use, the latency increases with a couple of 10s
of ms and I see a significant degradation of throughput (compared to when no
tunnels are used). The only exception is IP-in-IP, where I get similar
performance with and without tunnels, but it does unfortunately not work in
my scenario.

First, I thought this was caused by the different tunneling software, but
after measuring the processing time of the applications (xl2tp and
pptp-client) and when the packets are seen by the different iptables chains
(using LOG), these delays seem to be acceptable. However, one delay sticks
out. After the packet has been decapsulated and fed to PPP, it takes a
"long" time before it is seen again. My question is, can PPP be the cause of
the higher latency and lower throughput? 

Similar observations are made at both ends of the tunnel.

Thanks in advance for any help,
Kristian

