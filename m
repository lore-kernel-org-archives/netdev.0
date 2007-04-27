From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 9/9] net_device: dont include wext bits if not required
Date: Thu, 26 Apr 2007 20:50:13 -0400
Message-ID: <20070427005013.GA25332@tuxdriver.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180850.595757000@sipsolutions.net> <20070426165304.GC22576@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070426165304.GC22576-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 09:53:04AM -0700, Jean Tourrilhes wrote:
> On Tue, Apr 24, 2007 at 08:07:41PM +0200, Johannes Berg wrote:
> > This patch makes the wext bits in struct net_device depend on
> > CONFIG_WIRELESS_EXT.
> > 
> > Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> 
> 	I personally would not do that. Having conditional fields in
> "struct net_device" is very bad, it's a sure way to crash on modules
> in some cases. If I remember well, Jeff Garzik has been fighting those
> over the years.

I'm not sure I understand the reasoning here.  Without a doubt kernel
modules need to be built against the same configuration as the kernels
that are loading them.  So, conditional component of net_device should
not cause crashes.

FWIW, there are other conditionally compiled portions of net_device
(NETPOLL, NET_POLL_CONTROLLER).  I don't see the harm here.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
