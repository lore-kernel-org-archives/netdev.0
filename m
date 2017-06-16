From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 28/44] sparc: remove arch specific dma_supported
        implementations
Date: Fri, 16 Jun 2017 10:47:01 +0200
Message-ID: <20170616084701.GE10582@lst.de>
References: <20170608132609.32662-1-hch@lst.de> <20170608132609.32662-29-hch@lst.de> <CAGRGNgUJ3J_LEwhJ1rFHuzZ_J4OnTV9-DekcuT=N5z1pBKcb3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, x86@kernel.org,
        "Mailing List, Arm" <linux-arm-kernel@lists.infradead.org>,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-hexagon-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGRGNgUJ3J_LEwhJ1rFHuzZ_J4OnTV9-DekcuT=N5z1pBKcb3A@mail.gmail.com>
Sender: linux-hexagon-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2017 at 12:22:48AM +1000, Julian Calaby wrote:
> I'm guessing there's a few places that have DMA ops but DMA isn't
> actually supported. Why not have a common method for this, maybe
> "dma_not_supported"?

It's not common at all.  Except for sbus all dma API user first
call set_dma_mask which ends up in the dma_supported call.  sbus
is the weird outlier here.
