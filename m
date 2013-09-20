From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 42/51] DMA-API: usb: musb:
	use	platform_device_register_full() to avoid directly messing
	with dma	masks
Date: Fri, 20 Sep 2013 14:49:38 +0100
Message-ID: <20130920134938.GO25647@n2100.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnQk-0007sX-Ty@rmk-PC.arm.linux.org.uk> <20130920131125.GO26101@radagast>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 b43-dev@lists.infradead.org, linux-media@vger.kernel.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-tegra@vger.kernel.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-crypto@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <20130920131125.GO26101@radagast>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 08:11:25AM -0500, Felipe Balbi wrote:
> Hi,
> 
> On Fri, Sep 20, 2013 at 12:14:38AM +0100, Russell King wrote:
> > Use platform_device_register_full() for those drivers which can, to
> > avoid messing directly with DMA masks.  This can only be done when
> > the driver does not need to access the allocated musb platform device
> > from within its callbacks, which may be called during the musb
> > device probing.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> you want me to carry this one through my tree or you prefer getting my
> Acked-by ? Either way works for me:
> 
> Acked-by: Felipe Balbi <balbi@ti.com>
> 
> there's also the third option of me setting up a branch with only this
> patch and we both merge it, that'd also work.

I think this patch is sufficiently stand-alone that it should be fine
if you want to take it through your tree.  That may be better in the
long run to avoid conflicts with this patch and any future work in
this area during this cycle.

Thanks.
