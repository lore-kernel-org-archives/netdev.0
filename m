From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: skb_shared_info optimization
Date: Mon, 08 Jun 2009 00:22:31 -0700 (PDT)
Message-ID: <20090608.002231.101760669.davem@davemloft.net>
References: <4A2925E0.6060508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753201AbZFHHWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:22:30 -0400
In-Reply-To: <4A2925E0.6060508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Jun 2009 16:04:16 +0200

> skb_dma_unmap() is quite expensive for small packets, 
> because we use two different cache lines from skb_shared_info.
> 
> One to access nr_frags, one to access dma_maps[0]
> 
> Instead of dma_maps being an array of MAX_SKB_FRAGS + 1 elements,
> let dma_head alone in a new dma_head field, close to nr_frags,
> to reduce cache lines misses.
> 
> Tested on my dev machine (bnx2 & tg3 adapters), nice speedup !
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
