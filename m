From: David Miller <davem@davemloft.net>
Subject: Re: BUG: NULL pointer dereference in netif_carrier_off
Date: Thu, 10 Jan 2013 14:37:37 -0800 (PST)
Message-ID: <20130110.143737.1586417148052592077.davem@davemloft.net>
References: <CACzvQmaj1_r4DHJjU7K4JN7jywX8y0_j_EQ_6tC8VkGryMmQPQ@mail.gmail.com>
	<1357840590.27446.2331.camel@edumazet-glaptop>
	<1357842765.27446.2396.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.parkin@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab3AJWhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:37:38 -0500
In-Reply-To: <1357842765.27446.2396.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jan 2013 10:32:45 -0800

> [PATCH net-next] veth: fix a NULL deref in netif_carrier_off
> 
> In commit d0e2c55e7c94 (veth: avoid a NULL deref in veth_stats_one)
> we now clear the peer pointers in veth_dellink()
> 
> veth_close() must therefore make sure the peer pointer is set.
> 
> Reported-by: Tom Parkin <tom.parkin@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
