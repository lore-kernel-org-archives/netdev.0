From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: ethernet: ti: cpdma: switch to use genalloc
Date: Wed, 29 Jun 2016 04:19:11 -0400 (EDT)
Message-ID: <20160629.041911.971288115210875782.davem@davemloft.net>
References: <20160627090511.27487-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	ivan.khoronzhuk@linaro.org, lsorense@csclub.uwaterloo.ca,
	afzal.mohd.ma@gmail.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160627090511.27487-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Mon, 27 Jun 2016 12:05:11 +0300

> TI CPDMA currently uses a bitmap for tracking descriptors alloactions
> allocations, but The genalloc already handles the same and can be used
> as with special memory (SRAM) as with DMA cherent memory chank
> (dma_alloc_coherent()). Hence, switch to using genalloc and add
> desc_num property for each channel for limitation of max number of
> allowed descriptors for each CPDMA channel. This patch do not affect
> on net throuput.
> 
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> Tested-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied, thanks.
