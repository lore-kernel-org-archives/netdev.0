From: Andreas Henriksson <andreas@fatal.se>
Subject: XT_ALIGN changed to use ALIGN breaks iproute2
Date: Tue, 30 Mar 2010 11:28:29 +0200
Message-ID: <20100330092829.GA3106@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:41193 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755964Ab0C3J2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 05:28:13 -0400
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id C4762EB1E9
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 11:28:08 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexey (and everyone else)!

You updated the kernel header include/linux/netfilter/x_tables.h
in torvalds/linux-2.6.git commit 42107f5009da223daa800d6da6904d77297ae829
with the comment "Use ALIGN() macro while I'm at it for same types.".

When this header was synced into iproute2 the build broke because the
ALIGN macro apparently only is defined in kernel headers.

(For iproute2 the problem was introduced in
8ecdcce08319d0e39b0d32c1d17db3f69d85a35c and found by Stephen
and worked around in 609ceb807deba8e23 and edaaa11e5a3cf2c9c1a39)

I'm guessing the problem in the iproute2 header sync is just a heads
up for what's going to happen when distributions updates their
system headers to match linux 2.6.33.


Could someone who knows how the userspace version of the kernel
headers are generated please find a suitable solution?

-- 
Andreas Henriksson
