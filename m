From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: inetpeer_invalidate_tree() cleanup
Date: Wed, 20 Jun 2012 14:39:16 -0700 (PDT)
Message-ID: <20120620.143916.148839963180541405.davem@davemloft.net>
References: <1340200930.4604.1028.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754629Ab2FTVjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:39:18 -0400
In-Reply-To: <1340200930.4604.1028.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 16:02:10 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> No need to use cmpxchg() in inetpeer_invalidate_tree() since we hold
> base lock.
> 
> Also use correct rcu annotations to remove sparse errors
> (CONFIG_SPARSE_RCU_POINTER=y)
> 
> net/ipv4/inetpeer.c:144:19: error: incompatible types in comparison
> expression (different address spaces)
> net/ipv4/inetpeer.c:149:20: error: incompatible types in comparison
> expression (different address spaces)
> net/ipv4/inetpeer.c:595:10: error: incompatible types in comparison
> expression (different address spaces)
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
