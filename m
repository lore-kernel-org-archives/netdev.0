From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix crash in build_skb()
Date: Sat, 25 Apr 2015 17:32:10 -0400 (EDT)
Message-ID: <20150425.173210.137054898842699437.davem@davemloft.net>
References: <553AB56F.4000600@oracle.com>
	<1429916701.22254.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbDYVcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 17:32:14 -0400
In-Reply-To: <1429916701.22254.143.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Apr 2015 16:05:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When I added pfmemalloc support in build_skb(), I forgot netlink
> was using build_skb() with a vmalloc() area.
> 
> In this patch I introduce __build_skb() for netlink use,
> and build_skb() is a wrapper handling both skb->head_frag and
> skb->pfmemalloc
> 
> This means netlink no longer has to hack skb->head_frag
 ...
> Fixes: 79930f5892e ("net: do not deplete pfmemalloc reserve")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>

Applied, and since this fixes a patch I have queued up for -stable,
queued up for -stable as well.
