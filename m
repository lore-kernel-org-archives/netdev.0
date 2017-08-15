From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/8] MIPS: BCM63XX: add and use clkdev lookup support
Date: Tue, 15 Aug 2017 09:20:00 -0700
Message-ID: <b180fcb8-0282-3bad-aad0-4f1faaea73b0@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
To: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170802093429.12572-1-jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/02/2017 02:34 AM, Jonas Gorski wrote:
> This patchset adds and uses clckdev lookup support to name input clocks
> in various drivers more closely to their functions, or simplify their
> usage.
> 
> Since most of these patches touch arch/mips, it probably makes most
> sense to go through the MIPS tree.
> 
> The HSSPI driver was already updated previously to support a "pll"
> input with ff18e1ef04e2 ("spi/bcm63xx-hsspi: allow providing clock rate
> through a second clock"), so there is no need to touch it.
> 
> This patch series is part of an effort to modernize BCM63XX and clean up
> its drivers to eventually make them usable with BMIPS and device tree.

For this entire series:

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks!

> 
> Jonas Gorski (8):
>   MIPS: BCM63XX: add clkdev lookup support
>   MIPS: BCM63XX: provide periph clock as refclk for uart
>   tty/bcm63xx_uart: use refclk for the expected clock name
>   tty/bcm63xx_uart: allow naming clock in device tree
>   MIPS: BCM63XX: provide enet clocks as "enet" to the ethernet devices
>   bcm63xx_enet: just use "enet" as the clock name
>   MIPS: BCM63XX: move the HSSPI PLL HZ into its own clock
>   MIPS: BMIPS: name the refclk clock for uart
> 
>  .../bindings/serial/brcm,bcm6345-uart.txt          |   6 +
>  arch/mips/Kconfig                                  |   1 +
>  arch/mips/bcm63xx/clk.c                            | 181 ++++++++++++++++-----
>  arch/mips/boot/dts/brcm/bcm3368.dtsi               |   2 +
>  arch/mips/boot/dts/brcm/bcm63268.dtsi              |   2 +
>  arch/mips/boot/dts/brcm/bcm6328.dtsi               |   2 +
>  arch/mips/boot/dts/brcm/bcm6358.dtsi               |   2 +
>  arch/mips/boot/dts/brcm/bcm6362.dtsi               |   2 +
>  arch/mips/boot/dts/brcm/bcm6368.dtsi               |   2 +
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c       |   5 +-
>  drivers/tty/serial/bcm63xx_uart.c                  |   6 +-
>  11 files changed, 168 insertions(+), 43 deletions(-)
> 

-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
