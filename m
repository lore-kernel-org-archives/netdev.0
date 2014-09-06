From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: only pull headers into skb head
Date: Fri, 05 Sep 2014 22:35:47 -0700 (PDT)
Message-ID: <20140905.223547.1067550845666436634.davem@davemloft.net>
References: <1409966985.11872.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaIFFfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 01:35:48 -0400
In-Reply-To: <1409966985.11872.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Sep 2014 18:29:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Use the new fancy eth_get_headlen() to pull exactly the headers
> into skb->head.
> 
> This speeds up GRE traffic (or more generally tunneled traffuc),
> as GRO can aggregate up to 17 MSS per GRO packet instead of 8.
> 
> (Pulling too much data was forcing GRO to keep 2 frags per MSS)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric.
