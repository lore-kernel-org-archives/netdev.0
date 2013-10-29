From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 10:46:18 +0100
Message-ID: <4271216.r5b5qx4BLA@avalon>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<Pine.LNX.4.64.1310291009121.8404@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
	Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-k
To: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1310291009121.8404-0199iw4Nj15frtckUFj5Ag@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Simon and Guennadi,

On Tuesday 29 October 2013 10:12:17 Guennadi Liakhovetski wrote:
> On Tue, 29 Oct 2013, Laurent Pinchart wrote:
> > Hello,
> > 
> > This patch series, based on v3.12-rc7, prepares various Renesas drivers
> > for migration to multiplatform kernels by enabling their compilation or
> > otherwise fixing them on all ARM platforms. The patches are pretty
> > straightforward and are described in their commit message.
> > 
> > I'd like to get all these patches merged in v3.14. As they will need to go
> > through their respective subsystems' trees, I would appreciate if all
> > maintainers involved could notify me when they merge patches from this
> > series in their tree to help me tracking the merge status. I don't plan
> > to send pull requests individually for these patches, and I will repost
> > patches individually if changes are requested during review.
> > 
> > If you believe the issue should be solved in a different way (for instance
> > by removing the architecture dependency completely) please reply to the
> > cover letter to let other maintainers chime in.
> 
> Exactly this was my doubt. If we let these drivers build on all ARM
> platforms... Maybe we should just let them build everywhere? Unless there
> are real ARM dependencies. Maybe you could try to remove the restriction
> and try to build them all on x86?

My concern is that they might not build on some architectures for which I 
don't have a cross-compiler. For instance not all architecture define ioread32 
and iowrite32, which some drivers might rely on. What about depending on 
SUPERH || ARM || COMPILE_TEST to start with, in order not to push compilation 
breakages to mainline ?

> > Cc: Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
> > Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> > Cc: dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Cc: Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>
> > Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> > Cc: Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Cc: Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>
> > Cc: iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > Cc: Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
> > Cc: Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>
> > Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> > Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Cc: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Cc: Mauro Carvalho Chehab <m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
> > Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
> > Cc: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Cc: Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>
> > Cc: Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Cc: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
> > Cc: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > 
> > Laurent Pinchart (19):
> >   serial: sh-sci: Enable the driver on all ARM platforms
> >   DMA: shdma: Enable the driver on all ARM platforms
> >   i2c: sh_mobile: Enable the driver on all ARM platforms
> >   input: sh_keysc: Enable the driver on all ARM platforms
> >   iommu: shmobile: Enable the driver on all ARM platforms
> >   i2c: rcar: Enable the driver on all ARM platforms
> >   v4l: sh_vou: Enable the driver on all ARM platforms
> >   mmc: sdhi: Enable the driver on all ARM platforms
> >   mmc: sh_mmcif: Enable the driver on all ARM platforms
> >   mtd: sh_flctl: Enable the driver on all ARM platforms
> >   net: sh_eth: Set receive alignment correctly on all ARM platforms
> >   irda: sh_irda: Enable the driver on all ARM platforms
> >   pinctrl: sh-pfc: Enable the driver on all ARM platforms
> >   pwm: pwm-renesas-tpu: Enable the driver on all ARM platforms
> >   sh: intc: Enable the driver on all ARM platforms
> >   spi: sh_msiof: Enable the driver on all ARM platforms
> >   spi: sh_hspi: Enable the driver on all ARM platforms
> >   thermal: rcar-thermal: Enable the driver on all ARM platforms
> >   fbdev: sh-mobile-lcdcfb: Enable the driver on all ARM platforms
> >  
> >  drivers/dma/sh/Kconfig                | 2 +-
> >  drivers/dma/sh/shdmac.c               | 6 +++---
> >  drivers/i2c/busses/Kconfig            | 4 ++--
> >  drivers/input/keyboard/Kconfig        | 2 +-
> >  drivers/iommu/Kconfig                 | 2 +-
> >  drivers/media/platform/Kconfig        | 2 +-
> >  drivers/mmc/host/Kconfig              | 4 ++--
> >  drivers/mmc/host/tmio_mmc_dma.c       | 2 +-
> >  drivers/mtd/nand/Kconfig              | 2 +-
> >  drivers/net/ethernet/renesas/sh_eth.c | 2 +-
> >  drivers/net/ethernet/renesas/sh_eth.h | 2 +-
> >  drivers/net/irda/Kconfig              | 2 +-
> >  drivers/pinctrl/Makefile              | 2 +-
> >  drivers/pinctrl/sh-pfc/Kconfig        | 2 +-
> >  drivers/pwm/Kconfig                   | 2 +-
> >  drivers/sh/intc/Kconfig               | 2 +-
> >  drivers/spi/Kconfig                   | 4 ++--
> >  drivers/thermal/Kconfig               | 2 +-
> >  drivers/tty/serial/Kconfig            | 2 +-
> >  drivers/video/Kconfig                 | 6 +++---
> >  20 files changed, 27 insertions(+), 27 deletions(-)

-- 
Regards,

Laurent Pinchart
