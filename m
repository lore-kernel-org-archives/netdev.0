From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 0/7]: arm: lpc32xx: Device tree support
Date: Mon, 2 Apr 2012 13:45:04 +0000
Message-ID: <201204021345.04512.arnd@arndb.de>
References: <1333371364-21347-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org
To: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1333371364-21347-1-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 02 April 2012, Roland Stigge wrote:
> This is the first series of patches to introduce device tree support for the
> LPC32xx SoC. This series includes patches for the various subsystems to support
> device tree to be used later by the machine's initialization.
> 
> The patches apply to various subsystems:
> 
>  * staging/iio/adc
>  * rtc
>  * net
>  * arm-soc
>  * i2c
>  * wdt
> 
> Based on v3.4-rc1
> 
> You can also pull from
> 
>   git://git.antcom.de/linux-2.6 lpc32xx/dt
> 
> I'm CC'ing the various subsystem maintainers and lists who can each see what's
> going on and please pick their respective subsystem's changes. - Thanks!
> 
> Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>

Looks good overall.

I notice that you are missing the bindings for irq and gpio, which tend to be
quite important. Do you have another tree that has all the lpc32xx specific
parts or are these still under heavy development?

Do you plan to add DT support in parallel to the ATAGS based board you
already have, or do you plan to move everything over quickly?
In the latter case, it might be helpful to get Acks from the subsystem
maintainers and merge everything through arm-soc.

	Arnd
