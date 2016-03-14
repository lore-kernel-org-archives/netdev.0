From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: mediatek: use dma_addr_t correctly
Date: Mon, 14 Mar 2016 13:06:33 -0400 (EDT)
Message-ID: <20160314.130633.1932883457156537338.davem@davemloft.net>
References: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 15:07:10 +0100

> dma_alloc_coherent() expects a dma_addr_t pointer as its argument,
> not an 'unsigned int', and gcc correctly warns about broken
> code in the mtk_init_fq_dma function:
> 
> drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_init_fq_dma':
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:463:13: error: passing argument 3 of 'dma_alloc_coherent' from incompatible pointer type [-Werror=incompatible-pointer-types]
> 
> This changes the type of the local variable to dma_addr_t.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
