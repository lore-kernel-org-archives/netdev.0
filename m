From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gro: fix aggregation for skb using frag_list
Date: Mon, 29 Sep 2014 15:19:00 -0400 (EDT)
Message-ID: <20140929.151900.618302492132612563.davem@davemloft.net>
References: <1412012069.30721.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, erezsh@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbaI2TTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:19:02 -0400
In-Reply-To: <1412012069.30721.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Sep 2014 10:34:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> I added a regression for linear skb that traditionally force GRO
> to use the frag_list fallback.
> 
> Erez Shitrit found that at most two segments were aggregated and
> the "if (skb_gro_len(p) != pinfo->gso_size)" test was failing.
> 
> This is because pinfo at this spot still points to the last skb in the
> chain, instead of the first one, where we find the correct gso_size
> information.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> Reported-by: Erez Shitrit <erezsh@mellanox.com>

Applied and queued up for -stable, thanks Eric.
