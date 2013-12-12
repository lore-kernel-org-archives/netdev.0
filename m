From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: eth: davinci_cpdma: 64-bit phys/dma_addr_t
 cleanup
Date: Wed, 11 Dec 2013 19:54:17 -0500 (EST)
Message-ID: <20131211.195417.709076824951663618.davem@davemloft.net>
References: <1386805882-25360-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: olof@lixom.net
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1386805882-25360-1-git-send-email-olof@lixom.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Wed, 11 Dec 2013 15:51:20 -0800

> Silences the below warnings when building with ARM_LPAE enabled, which
> gives longer dma_addr_t by default:
> 
> drivers/net/ethernet/ti/davinci_cpdma.c: In function 'cpdma_desc_pool_create':
> drivers/net/ethernet/ti/davinci_cpdma.c:182:3: warning: passing argument 3 of 'dma_alloc_attrs' from incompatible pointer type [enabled by default]
> drivers/net/ethernet/ti/davinci_cpdma.c: In function 'desc_phys':
> drivers/net/ethernet/ti/davinci_cpdma.c:222:25: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/ti/davinci_cpdma.c:223:8: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Applied.
