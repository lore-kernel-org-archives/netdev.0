From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: shrinks struct net_device
Date: Thu, 16 Sep 2010 21:59:14 -0700 (PDT)
Message-ID: <20100916.215914.228953982.davem@davemloft.net>
References: <1284641893.3352.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751421Ab0IQE6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 00:58:55 -0400
In-Reply-To: <1284641893.3352.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Sep 2010 14:58:13 +0200

> commit ab95bfe01 (net: replace hooks in __netif_receive_skb) added
> rx_handler at wrong place, between two cache line aligned objects,
> creating a big hole (a full cache line)
> 
> Move rx_handler and rx_handler_data before rx_queue, filling existing
> hole.
> 
> Move master field in the cache line(s) used in receive path.
> 
> This saves 64 bytes (or L1_CACHE_BYTES), and avoids two possible
> cache misses in receive path.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks Eric.
