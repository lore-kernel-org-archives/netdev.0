From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: fix dma api length mismatch
Date: Fri, 18 Mar 2016 23:13:06 -0400 (EDT)
Message-ID: <20160318.231306.1347406577388515779.davem@davemloft.net>
References: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
	<56EAE2A8.5000206@gmail.com>
	<1458241026.7353.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, opendmb@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbcCSDNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 23:13:08 -0400
In-Reply-To: <1458241026.7353.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Mar 2016 11:57:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When un-mapping skb->data in __bcmgenet_tx_reclaim(),
> we must use the length that was used in original dma_map_single(),
> instead of skb->len that might be bigger (includes the frags)
> 
> We simply can store skb_len into tx_cb_ptr->dma_len and use it
> at unmap time.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
