From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-11-28
Date: Mon, 28 Nov 2011 19:55:16 -0500 (EST)
Message-ID: <20111128.195516.37800643865997337.davem@davemloft.net>
References: <20111128200221.GD2681@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111128200221.GD2681-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 28 Nov 2011 15:02:22 -0500

> Another big pull request -- my apologies!  I have a couple of
> sub-maintainers that had let their patch queues back-up a bit too
> long...
> 
> This pull request contains a lot of refactoring in the iwlegacy and
> ath6kl drivers.  mac80211 and rndis_wlan get some love as well.  Beyond
> that, there is a handful of small updates and minor fixes to some
> drivers and around the wireless stack.
> 
> Let me know if there are problems!

Pulled, but please push back on the ath6kl guys, they seem to have this
disease where they add tons of debugfs files for controlling things like
QoS from userspace instead of creating and using generic configuration
machanisms via netlink or similar that any other driver could support too.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
