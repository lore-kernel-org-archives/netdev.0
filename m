From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 9/9] net_device: dont include wext bits if not required
Date: Thu, 26 Apr 2007 09:53:04 -0700
Message-ID: <20070426165304.GC22576@bougret.hpl.hp.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180850.595757000@sipsolutions.net>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070424180850.595757000-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 08:07:41PM +0200, Johannes Berg wrote:
> This patch makes the wext bits in struct net_device depend on
> CONFIG_WIRELESS_EXT.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

	I personally would not do that. Having conditional fields in
"struct net_device" is very bad, it's a sure way to crash on modules
in some cases. If I remember well, Jeff Garzik has been fighting those
over the years.

	Jean
