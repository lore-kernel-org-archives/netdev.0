From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: allow large number of tx queues
Date: Sun, 23 Jun 2013 23:57:33 -0700 (PDT)
Message-ID: <20130623.235733.428837525618565559.davem@davemloft.net>
References: <1371657511.3252.324.camel@edumazet-glaptop>
	<20130619180709.GA15017@redhat.com>
	<1371716151.3252.390.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, hkchu@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab3FXG5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 02:57:34 -0400
In-Reply-To: <1371716151.3252.390.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jun 2013 01:15:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> netif_alloc_netdev_queues() uses kcalloc() to allocate memory
> for the "struct netdev_queue *_tx" array.
> 
> For large number of tx queues, kcalloc() might fail, so this
> patch does a fallback to vzalloc().
> 
> As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
> to kzalloc() flags to do this fallback only when really needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
