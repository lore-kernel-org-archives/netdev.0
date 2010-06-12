From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
Date: Fri, 11 Jun 2010 18:39:02 -0700 (PDT)
Message-ID: <20100611.183902.91325453.davem@davemloft.net>
References: <1276077416.2442.97.camel@edumazet-laptop>
	<20100609104100.GB7308@ff.dom.local>
	<1276085363.2442.125.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751839Ab0FLBiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 21:38:51 -0400
In-Reply-To: <1276085363.2442.125.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Jun 2010 14:09:23 +0200

> [PATCH v2] pkt_sched: gen_kill_estimator() rcu fixes
> 
> gen_kill_estimator() API is incomplete or not well documented, since
> caller should make sure an RCU grace period is respected before
> freeing stats_lock.
> 
> This was partially addressed in commit 5d944c640b4 
> (gen_estimator: deadlock fix), but same problem exist for all
> gen_kill_estimator() users, if lock they use is not already RCU
> protected.
> 
> A code review shows xt_RATEEST.c, act_api.c, act_police.c have this
> problem. Other are ok because they use qdisc lock, already RCU
> protected.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
