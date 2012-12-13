From: David Miller <davem@davemloft.net>
Subject: Re: GPF in skb_flow_dissect
Date: Thu, 13 Dec 2012 13:01:27 -0500 (EST)
Message-ID: <20121213.130127.1341933416292443904.davem@davemloft.net>
References: <20121213041644.GB1611@redhat.com>
	<1355376177.12271.244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, jasowang@redhat.com, netdev@vger.kernel.org
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab2LMSBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:01:31 -0500
In-Reply-To: <1355376177.12271.244.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Wed, 12 Dec 2012 21:22:57 -0800

> [PATCH] tuntap: dont use skb after netif_rx_ni(skb)
> 
> commit 96442e4242 (tuntap: choose the txq based on rxq) added
> a use after free.
> 
> Cache rxhash in a temp variable before calling netif_rx_ni()
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
