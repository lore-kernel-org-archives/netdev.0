From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 15:04:27 +0900
Message-ID: <20131029060427.GF11580@verge.net.au>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
 Linus Walleij <linus.walleij@linaro.org>,
 Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
 Joerg Roedel <joro@8bytes.org>, linux-sh@vger.kernel.org,
 Magnus Damm <magnus.damm@gmail.com>,
 Eduardo Valentin <eduardo.valentin@ti.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-serial@vger.kernel.org,
 linux-input@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Chris Ball <cjb@laptop.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, linux-pwm@vger.kernel.org,
 Samuel Ortiz <samuel@sortiz.org>, linux-pm@vger.kernel.org,
 Ian Molton <ian@mnementh.co.uk>, Mark Brown <broonie@kernel.org>,
 linux-arm-kernel@lists.infradead.org,
 Ser
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 12:46:48AM +0100, Laurent Pinchart wrote:
> Hello,
> 
> This patch series, based on v3.12-rc7, prepares various Renesas drivers
> for migration to multiplatform kernels by enabling their compilation or
> otherwise fixing them on all ARM platforms. The patches are pretty
> straightforward and are described in their commit message.
> 
> I'd like to get all these patches merged in v3.14. As they will need to go
> through their respective subsystems' trees, I would appreciate if all
> maintainers involved could notify me when they merge patches from this series
> in their tree to help me tracking the merge status. I don't plan to send pull
> requests individually for these patches, and I will repost patches
> individually if changes are requested during review.
> 
> If you believe the issue should be solved in a different way (for instance by
> removing the architecture dependency completely) please reply to the cover
> letter to let other maintainers chime in.

I think this is a step in a good direction.
However, I think it would be even better if the architecture dependency was
removed completely.

> 
> Cc: Chris Ball <cjb@laptop.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: dmaengine@vger.kernel.org
> Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Cc: Eduardo Valentin <eduardo.valentin@ti.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
> Cc: Ian Molton <ian@mnementh.co.uk>
> Cc: iommu@lists.linux-foundation.org
> Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
> Cc: Joerg Roedel <joro@8bytes.org>
> Cc: Linus Walleij <linus.walleij@linaro.org>
> Cc: linux-fbdev@vger.kernel.org
> Cc: linux-i2c@vger.kernel.org
> Cc: linux-input@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-media@vger.kernel.org
> Cc: linux-mmc@vger.kernel.org
> Cc: linux-mtd@lists.infradead.org
> Cc: linux-pm@vger.kernel.org
> Cc: linux-pwm@vger.kernel.org
> Cc: linux-serial@vger.kernel.org
> Cc: linux-spi@vger.kernel.org
> Cc: Magnus Damm <magnus.damm@gmail.com>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Mauro Carvalho Chehab <m.chehab@samsung.com>
> Cc: netdev@vger.kernel.org
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: Thierry Reding <thierry.reding@gmail.com>
> Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
> Cc: Vinod Koul <vinod.koul@intel.com>
> Cc: Wolfram Sang <wsa@the-dreams.de>
> Cc: Zhang Rui <rui.zhang@intel.com>
> 
> Laurent Pinchart (19):
>   serial: sh-sci: Enable the driver on all ARM platforms
>   DMA: shdma: Enable the driver on all ARM platforms
>   i2c: sh_mobile: Enable the driver on all ARM platforms
>   input: sh_keysc: Enable the driver on all ARM platforms
>   iommu: shmobile: Enable the driver on all ARM platforms
>   i2c: rcar: Enable the driver on all ARM platforms
>   v4l: sh_vou: Enable the driver on all ARM platforms
>   mmc: sdhi: Enable the driver on all ARM platforms
>   mmc: sh_mmcif: Enable the driver on all ARM platforms
>   mtd: sh_flctl: Enable the driver on all ARM platforms
>   net: sh_eth: Set receive alignment correctly on all ARM platforms
>   irda: sh_irda: Enable the driver on all ARM platforms
>   pinctrl: sh-pfc: Enable the driver on all ARM platforms
>   pwm: pwm-renesas-tpu: Enable the driver on all ARM platforms
>   sh: intc: Enable the driver on all ARM platforms
>   spi: sh_msiof: Enable the driver on all ARM platforms
>   spi: sh_hspi: Enable the driver on all ARM platforms
>   thermal: rcar-thermal: Enable the driver on all ARM platforms
>   fbdev: sh-mobile-lcdcfb: Enable the driver on all ARM platforms
> 
>  drivers/dma/sh/Kconfig                | 2 +-
>  drivers/dma/sh/shdmac.c               | 6 +++---
>  drivers/i2c/busses/Kconfig            | 4 ++--
>  drivers/input/keyboard/Kconfig        | 2 +-
>  drivers/iommu/Kconfig                 | 2 +-
>  drivers/media/platform/Kconfig        | 2 +-
>  drivers/mmc/host/Kconfig              | 4 ++--
>  drivers/mmc/host/tmio_mmc_dma.c       | 2 +-
>  drivers/mtd/nand/Kconfig              | 2 +-
>  drivers/net/ethernet/renesas/sh_eth.c | 2 +-
>  drivers/net/ethernet/renesas/sh_eth.h | 2 +-
>  drivers/net/irda/Kconfig              | 2 +-
>  drivers/pinctrl/Makefile              | 2 +-
>  drivers/pinctrl/sh-pfc/Kconfig        | 2 +-
>  drivers/pwm/Kconfig                   | 2 +-
>  drivers/sh/intc/Kconfig               | 2 +-
>  drivers/spi/Kconfig                   | 4 ++--
>  drivers/thermal/Kconfig               | 2 +-
>  drivers/tty/serial/Kconfig            | 2 +-
>  drivers/video/Kconfig                 | 6 +++---
>  20 files changed, 27 insertions(+), 27 deletions(-)
> 
> -- 
> Regards,
> 
> Laurent Pinchart
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
