From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: deprecate enqueue_root()
Date: Mon, 11 May 2015 14:17:49 -0400 (EDT)
Message-ID: <20150511.141749.1472638376555195012.davem@davemloft.net>
References: <1431360416.566.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbEKSRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 14:17:50 -0400
In-Reply-To: <1431360416.566.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 May 2015 09:06:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Only left enqueue_root() user is netem, and it looks not necessary :
> 
> qdisc_skb_cb(skb)->pkt_len is preserved after one skb_clone()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, applied, thanks Eric.
