From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.34-rc5-mmotm0428 - 2 RCU whinges in mac80211
Date: Thu, 06 May 2010 19:58:16 +0200
Message-ID: <1273168696.23199.0.camel@jlt3.sipsolutions.net>
References: <5820.1273167313@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5820.1273167313@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-05-06 at 13:35 -0400, Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org wrote:
> Spotted these in my dmesg, hopefully somebody is interested...
> 
> [   54.076863] wlan0: deauthenticating from 00:11:20:a4:4c:11 by local choice (reason=3)
> [   54.080580] 
> [   54.080581] ===================================================
> [   54.080584] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   54.080586] ---------------------------------------------------
> [   54.080589] net/mac80211/sta_info.c:858 invoked rcu_dereference_check() without protection!

I'm pretty sure I fixed those so there should be a patch on its way to
or in mainline somewhere.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
