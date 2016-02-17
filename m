From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] net: phy: spi_ks8995: add dependency on GPIO
Date: Tue, 16 Feb 2016 20:36:06 -0500 (EST)
Message-ID: <20160216.203606.1431228679408727525.davem@davemloft.net>
References: <1455372195-10825-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org, helmut.buchsbaum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455372195-10825-1-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sat, 13 Feb 2016 19:33:15 +0530

> The builds of allmodconfig of s390, m68k, tilegx, tilepro is failing
> with the error:
>  drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value'
>  drivers/net/phy/spi_ks8995.c:477:19: error: implicit declaration of function 'gpio_to_desc'
> 
> GPIO is now used to reset the switch so we should have a dependency on
> GPIOLIB. While adding the dependency also add COMPILE_TEST so that we
> can build test it.
> 
> Fixes: cd6f288cbaab ("net: phy: spi_ks8995: add support for resetting switch using GPIO")
> Cc: Helmut Buchsbaum <helmut.buchsbaum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
> ---
> 
> v2: added COMPILE_TEST and gpio/consumer.h

I'm going to apply Arnd's patch because it properly removes the
unnecessary linux/gpio.h include.

Thanks.
