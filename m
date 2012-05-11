From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] stmmac: add mixed burst for DMA
Date: Fri, 11 May 2012 18:12:59 -0400 (EDT)
Message-ID: <20120511.181259.845221725995971870.davem@davemloft.net>
References: <1336381953-18041-1-git-send-email-peppe.cavallaro@st.com>
	<1336381953-18041-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932518Ab2EKWNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:13:04 -0400
In-Reply-To: <1336381953-18041-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon,  7 May 2012 11:12:33 +0200

> -	int (*init) (void __iomem *ioaddr, int pbl, int fb, int burst_len,
> -			u32 dma_tx, u32 dma_rx);
> +	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
> +			int burst_len, u32 dma_tx, u32 dma_rx);

Fix the indentation of the arguments on the second line,
the first character must line up with the first column after
the function's openning parenthesis on the previous line.

> -static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb,
> +static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
>  			      int burst_len, u32 dma_tx, u32 dma_rx)

While you're here fix up that issue in the existing code here as well.

> -static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb,
> +static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
>  			     int burst_len, u32 dma_tx, u32 dma_rx)

Likewise.

> -	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
> +	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0,
> +	    mixed_burst = 0;

This is gross, just make a new "int" declaration for mixed_burst.
