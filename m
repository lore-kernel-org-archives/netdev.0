From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 23:48:17 -0400 (EDT)
Message-ID: <20141017.234817.1456444039400155118.davem@davemloft.net>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbaJRDsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:48:19 -0400
In-Reply-To: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Oct 2014 09:17:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line
> misses") added a regression for SO_BINDTODEVICE on IPv6.
> 
> This is because we still use inet6_iif() which expects that IP6 control
> block is still at the beginning of skb->cb[]
> 
> This patch adds tcp_v6_iif() helper and uses it where necessary.
> 
> Because __inet6_lookup_skb() is used by TCP and DCCP, we add an iif
> parameter to it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")

Applied.
