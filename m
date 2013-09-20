From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 39/51] DMA-API: others: use dma_set_coherent_mask()
Date: Fri, 20 Sep 2013 07:18:34 -0500
Message-ID: <20130920121834.GB7630@mtj.dyndns.org>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnNq-0007s4-HN@rmk-PC.arm.linux.org.uk>
 <20130920121652.GA7630@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
	devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
	dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
	linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Inki Dae <inki.dae@samsung.com>,
	Joonyoung Shim <jy0922.shim@samsung.com>,
	Seung-Woo Kim <sw0312.kim@samsung.com>,
	Kyun
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130920121652.GA7630@mtj.dyndns.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 07:16:52AM -0500, Tejun Heo wrote:
> On Fri, Sep 20, 2013 at 12:11:38AM +0100, Russell King wrote:
> > The correct way for a driver to specify the coherent DMA mask is
> > not to directly access the field in the struct device, but to use
> > dma_set_coherent_mask().  Only arch and bus code should access this
> > member directly.
> > 
> > Convert all direct write accesses to using the correct API.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
> The patch is pretty widely spread.  I don't mind how it gets routed
> but what's the plan?

Hmm... maybe hte pata_ixp4xx_cf.c part should be moved to the one
which updates pata_octeon_cf.c?

Thanks.

-- 
tejun
