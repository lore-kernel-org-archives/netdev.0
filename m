From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 14:47:22 -0400
Message-ID: <20090930184722.GD6364@tuxdriver.com>
References: <200909111648.50902.mb@bu3sch.de> <87ocosqykb.fsf@purkki.valot.fi> <1254322466.3959.5.camel@johannes.local> <200909301710.31082.mb@bu3sch.de> <1254324077.3959.7.camel@johannes.local> <4AC39A90.6060602@hartkopp.net> <4AC3A0F1.3060306@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC3A0F1.3060306-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2009 at 08:18:25PM +0200, Oliver Hartkopp wrote:
> Socket buffers that are generated and received inside softirqs or from process
> context must not use netif_rx() that's intended to be used from irq context only.
> 
> This patch introduces a new helper function netif_rx_ti(skb) that tests for
> in_interrupt() before invoking netif_rx() or netif_rx_ni().
> 
> It fixes the ratelimited kernel warning
> 
>         NOHZ: local_softirq_pending 08
> 
> in the mac80211 and can subsystems.
> 
> Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

http://bugzilla.kernel.org/show_bug.cgi?id=14278

Acked-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
