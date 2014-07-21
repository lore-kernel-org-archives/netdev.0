From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] net/macb: add scatter-gather hw feature
Date: Sun, 20 Jul 2014 21:13:37 -0700 (PDT)
Message-ID: <20140720.211337.211665722122921773.davem@davemloft.net>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
	<fda3a504240e1f6863107ef6bf1e78586671a030.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org
To: cyrille.pitchen@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fda3a504240e1f6863107ef6bf1e78586671a030.1405689937.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Fri, 18 Jul 2014 16:21:14 +0200

> +		if (tx_skb->mapped_as_page) {
> +			dma_unmap_page(&bp->pdev->dev, tx_skb->mapping,
> +				       tx_skb->size, DMA_TO_DEVICE);
> +		} else {
> +			dma_unmap_single(&bp->pdev->dev, tx_skb->mapping,
> +					 tx_skb->size, DMA_TO_DEVICE);
> +		}

Please do not use curly braces for basic block composed of a single statement.
