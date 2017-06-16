From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 27/44] sparc: remove leon_dma_ops
Date: Fri, 16 Jun 2017 10:45:42 +0200
Message-ID: <20170616084542.GD10582@lst.de>
References: <20170608132609.32662-1-hch@lst.de> <20170608132609.32662-28-hch@lst.de> <593E4B82.70306@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org,
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
To: Andreas Larsson <andreas@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42926 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752557AbdFPIpq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 04:45:46 -0400
Content-Disposition: inline
In-Reply-To: <593E4B82.70306@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 10:06:26AM +0200, Andreas Larsson wrote:
> Yes, it is needed. LEON systems are AMBA bus based. The common case here is 
> DMA over AMBA buses. Some LEON systems have PCI bridges, but in general 
> CONFIG_PCI is not a given.

Ok, and even for AMBA we use the pci ops, so I'll leave it in and drop
the comment from the commit.
