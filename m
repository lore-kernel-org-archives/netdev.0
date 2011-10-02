From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: oops in 2.6.38, possibly nf_conntrak_ipv4 related
Date: Sun, 2 Oct 2011 08:54:59 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1110020850050.11931@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:60653 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab1JBGzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Oct 2011 02:55:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by uplift.swm.pp.se (Postfix) with ESMTP id 9AA679C
	for <netdev@vger.kernel.org>; Sun,  2 Oct 2011 08:54:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello.

I just upgraded from ubuntu 10.10 (2.6.35) to 11.04 (2.6.38) on an amd64 
machine.

2.6.38-11-generic #50-Ubuntu SMP Mon Sep 12 21:17:25 UTC 2011 x86_64 x86_64 x86_64 GNU/Linux

About 12-14 hours after reboot, the machine oopsed and went offline. I 
took a picture of the trace which can be found here:

<http://swm.pp.se/IMG_0937.JPG>

To me, it looks like something went wrong in nf_conntrak_ipv4, but I am 
quite the novice regarding this.

I did not have any NAT rules enabled, the only iptables that is enabled 
are some simple port blocks with "-j REJECT --reject-with tcp-reset" for 
the world with a few exceptions (my own networks).

Any ideas? If this is the wrong place to turn to, pointers on where to go 
is much appreciated.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
