From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: RCU conversion of struct neighbour
Date: Wed, 06 Oct 2010 17:49:34 -0700 (PDT)
Message-ID: <20101006.174934.232737066.davem@davemloft.net>
References: <1286380456.9417.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751625Ab0JGAtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 20:49:13 -0400
In-Reply-To: <1286380456.9417.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Oct 2010 17:54:16 +0200

> This is the second step for neighbour RCU conversion.
> 
> (first was commit d6bf7817 : RCU conversion of neigh hash table)
> 
> neigh_lookup() becomes lockless, but still take a reference on found
> neighbour. (no more read_lock()/read_unlock() on tbl->lock)
> 
> struct neighbour gets an additional rcu_head field and is freed after an
> RCU grace period.
> 
> Future work would need to eventually not take a reference on neighbour
> for temporary dst (DST_NOCACHE), but this would need dst->_neighbour to
> use a noref bit like we did for skb->_dst.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
