From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 01/18] stmmac: share reset function
 between dwmac100 and dwmac1000
Date: Mon, 04 Jan 2016 22:25:49 -0500 (EST)
Message-ID: <20160104.222549.839329360046336198.davem@davemloft.net>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
	<1451912823-5245-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbcAEDZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:25:51 -0500
In-Reply-To: <1451912823-5245-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 4 Jan 2016 14:06:46 +0100

> @@ -376,7 +376,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
>  /* Specific DMA helpers */
>  struct stmmac_dma_ops {
>  	/* DMA core initialization */
> -	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
> +	int (*reset)(void __iomem *ioaddr);
> +	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
>  		     int burst_len, u32 dma_tx, u32 dma_rx, int atds);

Since you change the return type of the 'init' method, and this
changes the column of the openning parenthesis, you have to fix the
indentation of the argument list on the next line.
