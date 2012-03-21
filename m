From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix napi_reuse_skb() skb reserve
Date: Wed, 21 Mar 2012 16:56:24 -0400 (EDT)
Message-ID: <20120321.165624.972276388107342047.davem@davemloft.net>
References: <1332349083.5330.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab2CUU4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 16:56:40 -0400
In-Reply-To: <1332349083.5330.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Mar 2012 09:58:03 -0700

> napi->skb is allocated in napi_get_frags() using
> netdev_alloc_skb_ip_align(), with a reserve of NET_SKB_PAD +
> NET_IP_ALIGN bytes.
> 
> However, when such skb is recycled in napi_reuse_skb(), it ends with a
> reserve of NET_IP_ALIGN which is suboptimal.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks.
