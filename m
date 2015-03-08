From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: rework Rx queue init
Date: Sat, 07 Mar 2015 22:33:03 -0500 (EST)
Message-ID: <20150307.223303.2269656985860547081.davem@davemloft.net>
References: <20150306214500.B542F2214B2@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbCHDdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 22:33:05 -0500
In-Reply-To: <20150306214500.B542F2214B2@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Fri,  6 Mar 2015 13:45:00 -0800 (PST)

> In preparation for supporting multiple Rx queues:
> 1. Move the initialization of priv->num_rx_bds, priv->rx_bds, and
>    priv->rx_cbs from bcmgenet_init_rx_ring() to bcmgenet_init_dma()
>    since they are not specific to a single Rx queue. Mimics the Tx
>    init model where priv->num_tx_bds, priv->tx_bds, and priv->tx_cbs
>    are initialized in bcmgenet_init_dma().
> 2. Program DMA_MBUF_DONE_THRESH = 1 so that future Rx queues Q0-Q15
>    will get per-packet Rx interrupt.
> 3. Group DMA_START_ADDR, RDMA_READ_PTR, RDMA_WRITE_PTR, and DMA_END_ADDR
>    initialization together. Mimics the Tx init model.
> 4. There is 1-to-1 mapping between RxCBs and RxBDs.
>    Precalculate RxCB->bd_addr so that it can be used in the future.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
