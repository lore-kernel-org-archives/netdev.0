From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] sh_eth: SH_ETH should depend on HAS_DMA
Date: Wed, 10 Jul 2013 19:47:31 -0700 (PDT)
Message-ID: <20130710.194731.99871775347094227.davem@davemloft.net>
References: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 10 Jul 2013 23:03:34 +0200

> If NO_DMA=y:
> 
> drivers/built-in.o: In function `sh_eth_free_dma_buffer':
> drivers/net/ethernet/renesas/sh_eth.c:1103: undefined reference to `dma_free_coherent'
> drivers/net/ethernet/renesas/sh_eth.c:1110: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `sh_eth_ring_init':
> drivers/net/ethernet/renesas/sh_eth.c:1065: undefined reference to `dma_alloc_coherent'
> drivers/net/ethernet/renesas/sh_eth.c:1086: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `sh_eth_ring_format':
> drivers/net/ethernet/renesas/sh_eth.c:988: undefined reference to `dma_map_single'
> drivers/built-in.o: In function `sh_eth_txfree':
> drivers/net/ethernet/renesas/sh_eth.c:1220: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `sh_eth_rx':
> drivers/net/ethernet/renesas/sh_eth.c:1323: undefined reference to `dma_map_single'
> drivers/built-in.o: In function `sh_eth_start_xmit':
> drivers/net/ethernet/renesas/sh_eth.c:1954: undefined reference to `dma_map_single'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks Geert.
