From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: SYN packets are now simply consumed
Date: Mon, 25 Apr 2016 15:50:52 -0400 (EDT)
Message-ID: <20160425.155052.470165108676532761.davem@davemloft.net>
References: <1461301981.7627.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:50:55 -0400
In-Reply-To: <1461301981.7627.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Apr 2016 22:13:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We now have proper per-listener but also per network namespace counters
> for SYN packets that might be dropped.
> 
> We replace the kfree_skb() by consume_skb() to be drop monitor [1]
> friendly, and remove an obsolete comment.
> FastOpen SYN packets can carry payload in them just fine.
> 
> [1] perf record -a -g -e skb:kfree_skb sleep 1; perf report
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
