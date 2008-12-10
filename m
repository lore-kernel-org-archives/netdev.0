From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Micrel KS8695 integrated ethernet driver
Date: Tue, 09 Dec 2008 23:05:35 -0800 (PST)
Message-ID: <20081209.230535.161417535.davem@davemloft.net>
References: <1228741685.19000.91.camel@petitemort>
	<1228764912.3177.39.camel@achroite>
	<1228843809.17317.34.camel@petitemort>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: dsilvers@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbYLJHFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:05:34 -0500
In-Reply-To: <1228843809.17317.34.camel@petitemort>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Silverstone <dsilvers@simtec.co.uk>
Date: Tue, 09 Dec 2008 17:30:09 +0000

> +			mapping = dma_map_single(ksp->dev, skb->data,
> +						 MAX_RXBUF_SIZE,
> +						 DMA_FROM_DEVICE);
> +			if (!mapping) {

There is a proper way to check for DMA mapping failures.
Comparing against zero is not it :-)

> +	ksp->tx_buffers[buff_n].dma_ptr = dma_map_single(
> +		ksp->dev, skb->data, skb->len, DMA_TO_DEVICE);
> +	if (!ksp->tx_buffers[buff_n].dma_ptr) {

Likewise.
