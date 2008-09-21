From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Sun, 21 Sep 2008 19:36:00 +0200
Message-ID: <200809211936.00414.mb@bu3sch.de>
References: <20080921172316.GA6306@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921172316.GA6306-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 21 September 2008 19:23:17 Evgeniy Polyakov wrote:
> Hi.
> 
> Following bug exists in the ipw2100 driver/firmware for years and Intel
> folks never responded to zillions bugzilla entries and forum notices in
> the internet with some patch or firmware update (although did request
> dmesg and debug info, and received them).
> 
> ipw2100: Fatal interrupt. Scheduling firmware restart.
> 
> I believe it is a firmware bug because after driver is unloaded and
> loaded back again wireless adapter usually starts working (for small
> amount of time though). My conspiracy feeling can suggest, that it may
> be kind of a force to buy a new one, or trivial error in the firmware,
> when it writes to the same place in the flash and essentially given cell
> became dead or whatever else.
> 
> Intel folks, please fix this problem, I see no other way to force you to do
> this than to mark ipw2100 driver as broken, since that is what it is.

You are pretty funny, actually. :)

I think the bug should be fixed, but what makes _you_ think you can _force_
anybody to do so?

> Signed-off-by: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
> 
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index 9931b5a..c24fc6a 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -125,7 +125,7 @@ config PCMCIA_RAYCS
>  
>  config IPW2100
>  	tristate "Intel PRO/Wireless 2100 Network Connection"
> -	depends on PCI && WLAN_80211
> +	depends on PCI && WLAN_80211 && BROKEN
>  	select WIRELESS_EXT
>  	select FW_LOADER
>  	select IEEE80211
> 



-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
