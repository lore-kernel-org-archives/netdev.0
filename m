From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/3] net: Sanitizing hrtimer usage in
 net/sched/sch_cbq.c
Date: Sun, 12 Jul 2009 13:57:32 -0700 (PDT)
Message-ID: <20090712.135732.157815709.davem@davemloft.net>
References: <20090709215455.703939259@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, peterz@infradead.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbZGLU53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 16:57:29 -0400
In-Reply-To: <20090709215455.703939259@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 09 Jul 2009 21:59:18 -0000

> While looking at the "Soft-Lockup/Race in networking in 2.6.31-rc1+195
> ( possibly caused by netem)" issue (http://lkml.org/lkml/2009/7/2/519)
> I noticed some serious problems in the hrtimer related code of
> net/sched/sched/sch_cbq.c.
> 
> The following patch series addresses these.
> 
> I'm not entirely sure whether patch [1/3] covers all possible
> concurrent modifications, but it fixes the most obvious ones. The
> remaining details are left to the networking experts.
> 
> Patches [1/3] and [2/3] might be stable material as well.

I'm holding off on this entire set until we figure out what
to really do with the CBQ hrtimer situation.  See my reply
to patch #1, thanks.
