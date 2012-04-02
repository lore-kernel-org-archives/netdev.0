From: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 0/7]: arm: lpc32xx: Device tree support
Date: Mon, 02 Apr 2012 16:02:17 +0200
Message-ID: <4F79B169.5010909@antcom.de>
References: <1333371364-21347-1-git-send-email-stigge@antcom.de> <201204021345.04512.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201204021345.04512.arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 04/02/2012 03:45 PM, Arnd Bergmann wrote:
>> Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
>
> Looks good overall.

Thanks for your mails, I'm just integrating your suggestions.

> I notice that you are missing the bindings for irq and gpio, which
> tend to be
> quite important. Do you have another tree that has all the lpc32xx
> specific
> parts or are these still under heavy development?

Yes, still under development. GPIO is subject to an open minor issue
(will post an RFC later), and irq is part of the main mach-lpc32xx dt
switch - I have DT-irq already working, but I need to OF'ize lcd and usb
to complete.

> Do you plan to add DT support in parallel to the ATAGS based board you
> already have, or do you plan to move everything over quickly?

For the LPC32xx specific things, including arch/arm/mach-lpc32xx, I will
switch over to DT quickly, eliminating phy3250.c by replacing with a
respective dts file.

The other subsystems changes (pnx*) can and should be dual DT/non-DT to
support other platforms and users who still use it in a non-DT way.

> In the latter case, it might be helpful to get Acks from the subsystem
> maintainers and merge everything through arm-soc.

Yes, sounds reasonable regarding the LPC32xx specific bits like wdt and
adc. Is there sth. I can do about it?

Thanks all,

Roland
