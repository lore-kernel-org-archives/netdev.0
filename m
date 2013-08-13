From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix init_dma_desc_rings() to handle errors
Date: Mon, 12 Aug 2013 22:11:50 -0700 (PDT)
Message-ID: <20130812.221150.1978051574307183933.davem@davemloft.net>
References: <1392383.ZcinuGX9SF@amdc1032>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: b.zolnierkie@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab3HMFLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 01:11:51 -0400
In-Reply-To: <1392383.ZcinuGX9SF@amdc1032>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Date: Fri, 09 Aug 2013 14:02:08 +0200

> In stmmac_init_rx_buffers():
> * add missing handling of dma_map_single() error
> * remove superfluous unlikely() optimization while at it
> 
> Add stmmac_free_rx_buffers() helper and use it in dma_free_rx_skbufs().
> 
> In init_dma_desc_rings():
> * add missing handling of kmalloc_array() errors
> * fix handling of dma_alloc_coherent() and stmmac_init_rx_buffers() errors
> * make function return an error value on error and 0 on success
> 
> In stmmac_open():
> * add handling of init_dma_desc_rings() return value
> 
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Applied, thanks.
