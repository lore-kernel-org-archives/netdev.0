From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lpc_eth: add missing ndo_change_mtu()
Date: Mon, 11 Jun 2012 13:13:44 -0700 (PDT)
Message-ID: <20120611.131344.140847541249729239.davem@davemloft.net>
References: <1339406640.6001.1896.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stigge@antcom.de, kevin.wells@nxp.com,
	aletes.xgr@gmail.com, srinivas.bakki@nxp.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab2FKUNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 16:13:45 -0400
In-Reply-To: <1339406640.6001.1896.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Jun 2012 11:24:00 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> lpc_eth does a copy of transmitted skbs to DMA area, without checking
> skb lengths, so can trigger buffer overflows :
> 
> memcpy(pldat->tx_buff_v + txidx * ENET_MAXF_SIZE, skb->data, len);
> 
> One way to get bigger skbs is to allow MTU changes above the 1500 limit.
> 
> Calling eth_change_mtu() in ndo_change_mtu() makes sure this cannot
> happen.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
