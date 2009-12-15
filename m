From: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 18:20:35 +0800
Message-ID: <20091215102035.GJ28375@buzzloop.caiaq.de>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
 <20091215.014308.77044043.davem@davemloft.net>
 <1260871411.3692.4.camel@johannes.local>
 <1260871634.3692.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, m.hirsch-5g8ninUHluJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1260871634.3692.6.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 11:07:14AM +0100, Johannes Berg wrote:
> On Tue, 2009-12-15 at 11:03 +0100, Johannes Berg wrote:
> 
> > Since you indicate the kernel crashed, it is likely that libertas is
> > treating the buffer as a string, instead of an SSID.

Ok, I dodn't know that - thanks for pointing it out. In my setup here,
SSIDs are always valid alphanumeric strings, and I was mislead by the
comment that mentions the NULL-termination.

> drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid|grep '%s'
> assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
> assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
> assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid length %u\n",
> scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",

Those macros are stubbed out as nops in my setup, so they can
unfortunately not be the reason. I'll dig deeper :)

Thanks,
Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
