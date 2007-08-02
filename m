From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Thu, 2 Aug 2007 15:58:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708021557280.5150@anakin>
References: <200707271857.24162.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754839AbXHBN7E@vger.kernel.org>
In-Reply-To: <200707271857.24162.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Jul 2007, Michael Buesch wrote:
> The Sonics Silicon Backplane is a mini-bus used on
> various Broadcom chips and embedded devices.
> Devices using the SSB include b44, bcm43xx and various
> Broadcom based wireless routers.
> A b44 and bcm43xx port and a SSB based OHCI driver is available.

> --- a/drivers/Kconfig
> +++ b/drivers/Kconfig
> @@ -58,6 +58,8 @@ source "drivers/power/Kconfig"
>  
>  source "drivers/hwmon/Kconfig"
>  
> +source "drivers/ssb/Kconfig"
> +
>  source "drivers/mfd/Kconfig"
>  
>  source "drivers/media/Kconfig"

> --- /dev/null
> +++ b/drivers/ssb/Kconfig
> @@ -0,0 +1,92 @@
> +menu "Sonics Silicon Backplane"
> +
> +config SSB
> +	tristate "Sonics Silicon Backplane support"
> +	depends on EXPERIMENTAL

Hence this will show up on all platforms?

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
