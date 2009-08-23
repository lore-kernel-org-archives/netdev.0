From: Jar <jar@pcuf.fi>
Subject: RX/TX bytes counter differences in eth0 and eth1 when using NAT
Date: Sun, 23 Aug 2009 13:32:40 +0300
Message-ID: <4A911AC8.7010309@pcuf.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox2.netikka.net ([213.250.81.203]:51900 "EHLO
	mbox2.netikka.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755883AbZHWKxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 06:53:25 -0400
Received: from netlandzone.dyndns.org (g389.ip14.netikka.fi [94.22.103.133])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mbox2.netikka.net (Postfix) with ESMTP id D6C9A4080B0
	for <netdev@vger.kernel.org>; Sun, 23 Aug 2009 13:32:40 +0300 (EEST)
Received: from [192.168.0.33] (gto.netland.fin [192.168.0.33])
	by netlandzone.dyndns.org (8.14.3/8.14.3) with ESMTP id n7NAWe8q025065
	for <netdev@vger.kernel.org>; Sun, 23 Aug 2009 13:32:40 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

It seems that RX/TX bytes counters doesn't increase at the same speed in 
eth0 side than they do in eth1 side, even physically the same data which 
is coming in via eth1 should be coming out via eth0. Is this excepted?

Kernel is 2.6.27.30-170.2.82.fc10.i686 and eth0 (lan) and eth1 (wan) and 
there is iptables nat between lan and wan interfaces.

-- 
Best Regards, Jar
