From: "Birger Harzenetter" <WIMPy@yeti.dk>
Subject: [bug] sunhme unable to receive IPv4 unicasts
Date: Fri, 24 Oct 2014 00:04:42 +0200
Message-ID: <op.xn7d94v644i3fq@lx3.fl.yeti.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed	delsp=yes
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e183095026.adsl.alicedsl.de ([85.183.95.26]:57149 "EHLO
	lx3.fl.yeti.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbaJWWSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 18:18:12 -0400
Received: from lx3.fl.yeti.dk (IDENT:502@lx3.fl.yeti.dk [192.168.7.23])
	by lx3.fl.yeti.dk (8.14.9/8.11.4) with ESMTP id s9NM4g7B009772
	for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 00:04:42 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 from https://bugzilla.kernel.org/show_bug.cgi?id=86731

Any kind of transmission is fine.
Reception of IPv4 broadcast works
Reception of non-IP works (pppoe tested)
But IPv4 unicasts don't show up at all.
IPv6 not tested

Additional tests:
I tried to set promiscous mode, but still no trace of unicasts seen with  
tcpdump.

Last known working version: 3.15.10

   Greetings,
     WIMPy
