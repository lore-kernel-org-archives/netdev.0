From: Andreas Henriksson <andreas@fatal.se>
Subject: iproute2 syntax change in tc police?
Date: Wed, 02 Jan 2008 00:39:11 +0100
Message-ID: <1199230752.16358.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:48203 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbYAAXf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 18:35:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Patrick McHardy!

We have recently updated iproute in debian and have reports about the
new version breaking shorewall generated scripts. 

The original bug-report can be found at:
http://bugs.debian.org/458539


Commands like "tc filter add dev ppp0 parent ffff: protocol ip prio 50
u32 match ip src 0.0.0.0/0 police rate 4mbit burst 10k drop flowid :1"
apparently no longer works. The flowid is not accepted anymore.
Reverting commit 720a2e8d99... which you authored seems to "fix" this.

http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff;h=720a2e8d990707749b2cafa77ab3cd2b8241ec47

I guess the flowid is invalid syntax, but that it just got ignored
instead of caught before... 
Could you please have a look and tell me what you think about this?


-- 
Regards,
Andreas Henriksson

