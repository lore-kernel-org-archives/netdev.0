From: Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: change cfg80211 regulatory domain info as
 debug messages
Date: Mon, 16 Nov 2015 09:58:45 +0800
Message-ID: <20151116015845.GA3439@dhcp-128-65.nay.redhat.com>
References: <20151115073105.GA18846@dhcp-128-65.nay.redhat.com>
 <20151115192547.3fd1b3cc@mir>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: Stefan Lippers-Hollmann <s.l-h-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151115192547.3fd1b3cc@mir>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 11/15/15 at 07:25pm, Stefan Lippers-Hollmann wrote:
> Hi
> 
> On 2015-11-15, Dave Young wrote:
> > cfg80211 module prints a lot of messages like below. Actually printing
> > once is acceptable but sometimes it will print again and again, it looks
> > very annoying. It is better to change these detail messages to debugging
> > only.
> 
> It is a lot of info, easily repeated 3 times on boot, but it's also the
> only real chance to determine why you ended up with the regulatory 
> domain settings you got, rather than just the values itself. Given that
> a lot (most?) of officially shipping wireless devices are misconfigured
> (wrong EEPROM regdom settings for the region they're sold in) and 
> considering that the limits can even change at runtime (IEEE 802.11d), 
> it is imho quite important not just to be able what the current 
> restrictions (iw reg get) are, but also why the kernel settled on those.

If it is really important then a kernel cmdline param to disable the logs
sounds better?

Thanks
Dave
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
