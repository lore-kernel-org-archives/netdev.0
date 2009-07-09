From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 0/3]  net: Sanitizing hrtimer usage in net/sched/sch_cbq.c
Date: Thu, 09 Jul 2009 21:59:18 -0000
Message-ID: <20090709215455.703939259@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:37927 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754577AbZGIV7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 17:59:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at the "Soft-Lockup/Race in networking in 2.6.31-rc1+195
( possibly caused by netem)" issue (http://lkml.org/lkml/2009/7/2/519)
I noticed some serious problems in the hrtimer related code of
net/sched/sched/sch_cbq.c.

The following patch series addresses these.

I'm not entirely sure whether patch [1/3] covers all possible
concurrent modifications, but it fixes the most obvious ones. The
remaining details are left to the networking experts.

Patches [1/3] and [2/3] might be stable material as well.

Thanks,

	tglx

