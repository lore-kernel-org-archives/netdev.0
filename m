From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/44] sparc: remove leon_dma_ops
Date: Thu, 08 Jun 2017 10:22:35 -0400 (EDT)
Message-ID: <20170608.102235.262414851920420864.davem@davemloft.net>
References: <20170608132609.32662-1-hch@lst.de>
        <20170608132609.32662-28-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hch@lst.de
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-28-hch@lst.de>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Thu,  8 Jun 2017 15:25:52 +0200

> We can just use pci32_dma_ops.
> 
> Btw, given that leon is 32-bit and appears to be PCI based, do even need
> the special case for it in get_arch_dma_ops at all?

I would need to defer to the LEON developers on that, but they haven't
been very actively lately so whether you'll get a response or not is
hard to predict.

> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>
