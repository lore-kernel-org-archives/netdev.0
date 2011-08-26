From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2011-08-26
Date: Fri, 26 Aug 2011 12:36:20 -0400 (EDT)
Message-ID: <20110826.123620.2128524809929669115.davem@davemloft.net>
References: <20110826151758.GH2579@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110826151758.GH2579-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 26 Aug 2011 11:17:58 -0400

> Here is a round of fixes intended for 3.1...
> 
> The biggest portion are Bluetooth fixes.  Gustavo describes them
> thusly:
> 
> 	Some fixes for 3.1! It looks a lot of fixes but some of them
> 	are the same fix applied to different files. Here we have a
> 	fix for a wrong timer value from Chen Ganir, a lock balance
> 	fix from Dan Carpenter, regression fix with the HCI Reset
> 	command from Szymon Janc, a fix to not show error messages on
> 	btusb device disconnect from Paul Bolle. Support for Toshiba
> 	AR30XX from Ricardo Mendoza. And finally a bunch of fixes
> 	from Peter Hurley, there are some lost wake up, deadlocks and
> 	memort leaks fixes. Most of them fixes regressions introduced
> 	by the move to the kthread API.
> 
> In addition, we have a locking fix for carl9170, a bcma fix to enable
> driver loading via udev, a wl12xx fix to properly advertise the
> maximum number of SSIDs for scanning, another wl12xx fix to properly
> check a return code in order to avoid a possible oops, and a third
> wl12xx fix to remove a broken testmode function with locking problems
> (among others).  Also included is a suspend/resume fix for ath9k,
> a fix for reading improper MAC addresses on ath9k, a suspend/resume
> fix for mac80211, and a suspend/resume fix for rt2x00 as well.

Pulled, thanks John!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
