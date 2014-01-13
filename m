From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: call gro handler for
 encapsulated frames
Date: Mon, 13 Jan 2014 11:44:07 -0800 (PST)
Message-ID: <20140113.114407.333625675538885311.davem@davemloft.net>
References: <1389292213.31367.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbaAMToI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:44:08 -0500
In-Reply-To: <1389292213.31367.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jan 2014 10:30:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In order to use the native GRO handling of encapsulated protocols on
> mlx4, we need to call napi_gro_receive() instead of netif_receive_skb()
> unless busy polling is in action.
> 
> While we are at it, rename mlx4_en_cq_ll_polling() to
> mlx4_en_cq_busy_polling()
> 
> Tested with GRE tunnel : GRO aggregation is now performed on the
> ethernet device instead of being done later on gre device.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
