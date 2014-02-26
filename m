From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tcp: use NET_INC_STATS()
Date: Wed, 26 Feb 2014 15:20:08 -0500 (EST)
Message-ID: <20140226.152008.1482124169770558659.davem@davemloft.net>
References: <20140219193038.GC1179@order.stressinduktion.org>
	<1392839209.18849.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393331463.2316.139.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaBZUUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:20:11 -0500
In-Reply-To: <1393331463.2316.139.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Feb 2014 04:31:03 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES can only be incremented
> in tcp_transmit_skb() from softirq (incoming message or timer
> activation), it is better to use NET_INC_STATS() instead of
> NET_INC_STATS_BH() as tcp_transmit_skb() can be called from process
> context.
> 
> This will avoid copy/paste confusion when/if we want to add
> other SNMP counters in tcp_transmit_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
