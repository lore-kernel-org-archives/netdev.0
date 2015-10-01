From: "L. A. Walsh" <lkml@tlinx.org>
Subject: WARNING: iputils is not very fresh, upgrade is recommended; bug in
 iputils or kernel?
Date: Wed, 30 Sep 2015 17:46:26 -0700
Message-ID: <560C8262.6030405@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ishtar.tlinx.org ([173.164.175.65]:34380 "EHLO
	Ishtar.hs.tlinx.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbbJABQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 21:16:37 -0400
Received: from [192.168.4.12] (Athenae [192.168.4.12])
	by Ishtar.hs.tlinx.org (8.14.9/8.14.4/SuSE Linux 0.8) with ESMTP id t910kRxm060177
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 17:46:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the comment in the code:
---
            /* Sigh, IP_RECVERR for raw socket
             * was broken until 2.4.9. So, we ignore
             * the first error and warn on the second.
             */
            if (once++ == 1)
              fprintf(stderr, "\rWARNING: kernel is not very fresh, 
upgrade is recommended.\n");

----
When I first saw the error I wondered how fresh my kernel had
to be to pass iputils' tests, since I'm running on:

Ishtar:packages/build/iputils-s20121221> uname -a
Linux Ishtar 4.1.0-Isht-Van #2 SMP PREEMPT Tue Jun 23 07:52:09 PDT 2015 
x86_64 x86_64 x86_64 GNU/Linux

So I looked at code  Um... why is iputils thinking
that 4.1.0 < 2.4.9 -- or that 4.1.0 is older than
2.4.9?

I humbly submit that 4.1.0, released in 2015 is
unquestionably 'fresher' than the date on iputils of 2012.

Does this mean the check in iputils is faulty w/r/t new
kernels, or do new kernels have a *SERIOUS* regression?
