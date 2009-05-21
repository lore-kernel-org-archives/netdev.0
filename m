From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-05-20
Date: Wed, 20 May 2009 17:34:08 -0700 (PDT)
Message-ID: <20090520.173408.126761158.davem@davemloft.net>
References: <20090520193446.GA27441@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090520193446.GA27441-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 20 May 2009 15:34:47 -0400

> Another volley of fixes intended for 2.6.30 -- I know the velocity
> is a bit high for this part of the cycle, but these are mostly small
> and well-tested.
> 
> The one from me is a "brown paper bag" fix.  My earlier attempt to fix
> the potential buffer overflow in airo was actually a no-op due to an
> (unknown to me) type overflow... :-(
> 
> The ath5k fixes from Forrest Zhang and Pavel Roskin together fix some
> regressions with 5GHz operation.  The one from Fabio Rossi avoids an
> infinite loop reported by Stephen Rostedt.
> 
> The wext fix addresses a possible buffer overflow.  The cfg80211 fix
> addresses a user-reported oops.  The one from Roel avoids and index
> past the end of an array.
> 
> One of iwlwifi patches avoids a deadlock.  The other iwlwifi patch
> simply enables the use of the firmware image they just released.
> That one is worth taking for 2.6.30 because the new firmware fixes
> a couple of bugs that show-up as kernel bug reports.
> 
> Please let me know if there are problems!

Pulled, thanks John!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
