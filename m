From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/30] Swap over NFS -v17
Date: Thu, 20 Mar 2008 21:10:42 +0100
Message-ID: <20080320201042.675090000@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep11-int.chello.at ([62.179.121.31]:62461 "EHLO
	viefep11-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbYCTUVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:21:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Patches against v2.6.25-rc5-mm1, also online at:
  http://programming.kicks-ass.net/kernel-patches/vm_deadlock/v2.6.25-rc5-mm1/

A quick post to keep people up-to-date and show I didn't forget about this :-)

The biggest changes are in the reservation code, introduction of allocation
helpers significantly cleaned up the rest of the code.

I still need to go through that and write more comments, but I wanted to get
this out there so people can have a look.

I also added Neil's excellent writeup to Documentation/ - I hope I didn't
ruin it too much :-)




