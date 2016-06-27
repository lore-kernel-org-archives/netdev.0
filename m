From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2] net: ethernet: ti: cpdma: switch to use genalloc
Date: Mon, 27 Jun 2016 14:12:33 +0530
Message-ID: <5770E6F9.2010809@ti.com>
References: <20160624114338.26933-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624114338.26933-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 June 2016 05:13 PM, Grygorii Strashko wrote:
> TI CPDMA currently uses a bitmap for tracking descriptors alloactions
> allocations, but The genalloc already handles the same and can be used
> as with special memory (SRAM) as with DMA cherent memory chank
> (dma_alloc_coherent()). Hence, switch to using genalloc and add
> desc_num property for each channel for limitation of max number of
> allowed descriptors for each CPDMA channel. This patch do not affect
> on net throuput.
> 
> Tested-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
