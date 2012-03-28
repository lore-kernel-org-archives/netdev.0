From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eql: dont rely on HZ=100
Date: Tue, 27 Mar 2012 22:47:27 -0400 (EDT)
Message-ID: <20120327.224727.30292313009301823.davem@davemloft.net>
References: <1332835965.3248.2.camel@edumazet-laptop>
	<1332836241.2058.35.camel@shinybook.infradead.org>
	<1332838320.3248.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab2C1Csi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:48:38 -0400
In-Reply-To: <1332838320.3248.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Mar 2012 01:52:00 -0700

> [PATCH] eql: dont rely on HZ=100
> 
> HZ is more likely to be 1000 these days.
> 
> timer handlers are run from softirq, no need to disable bh
> 
> skb priority 1 is TC_PRIO_FILLER
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

Strange we export this EQL_DEFAULT_RESCHED_IVAL to userspace, where
HZ will take on a different value I think, something akin to USER_HZ.

Anyways, that's a different unrelated problem to the bug you're
fixing.
