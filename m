From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-07-02
Date: Sat, 05 Jul 2008 21:47:52 -0700 (PDT)
Message-ID: <20080705.214752.85024966.davem@davemloft.net>
References: <20080630215651.GA666@tuxdriver.com>
	<20080702193710.GA4682@tuxdriver.com>
	<20080702202653.GA10719@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080702202653.GA10719-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 2 Jul 2008 16:26:53 -0400

> Here is another slew of updates for 2.6.27.  The bulk of this batch is
> for iwlwifi, with some mac80211 and other bits thrown-in.
> 
> Let me know if there are problems!

Pulled and pushed back out to net-next-2.6, thanks.

Here are some warnings I noticed during an allmodconfig build
on sparc64, please fix:

drivers/net/wireless/hostap/hostap_hw.c:3422: warning: 'prism2_suspend' defined but not used
drivers/net/wireless/iwlwifi/iwl-rfkill.c:114: warning: label 'freed_rfkill' defined but not used

I'll take on the net-2.6 merge into net-next-2.6 next.

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
