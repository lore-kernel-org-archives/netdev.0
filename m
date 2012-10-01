From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/3] net: add gro_cells infrastructure
Date: Mon, 01 Oct 2012 17:04:05 -0400 (EDT)
Message-ID: <20121001.170405.937698761095534569.davem@davemloft.net>
References: <1348750077.5093.1224.camel@edumazet-glaptop>
	<1348788457.10741.39.camel@deadeye.wl.decadent.org.uk>
	<1348810145.5093.1887.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab2JAVEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:04:06 -0400
In-Reply-To: <1348810145.5093.1887.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Sep 2012 07:29:05 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> This adds a new include file (include/net/gro_cells.h), to bring GRO
> (Generic Receive Offload) capability to tunnels, in a modular way.
> 
> Because tunnels receive path is lockless, and GRO adds a serialization
> using a napi_struct, I chose to add an array of up to
> DEFAULT_MAX_NUM_RSS_QUEUES cells, so that multi queue devices wont be
> slowed down because of GRO layer.
> 
> skb_get_rx_queue() is used as selector.
> 
> In the future, we might add optional fanout capabilities, using rxhash
> for example.
> 
> With help from Ben Hutchings who reminded me
> netif_get_num_default_rss_queues() function.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Applied.
