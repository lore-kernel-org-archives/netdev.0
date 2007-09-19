From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 11:59:03 -0700 (PDT)
Message-ID: <20070919.115903.75429061.davem@davemloft.net>
References: <20070919181005.GB5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070919181005.GB5483-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 19 Sep 2007 14:10:05 -0400

> This patch adds z1211 (previously known as zd1211rw-mac80211),
> a driver for Zydas ZD1211 hardware.  This driver has proven very
> robust -- Fedora 7 uses this driver and I don't think I have any open
> bugzillas for it.  Either the driver works well, or no one as using
> it...given the common availability of the hardware, I have to presume
> the former. :-)
> 
> This driver is mostly a port of zd1211rw to the mac80211
> infrastructure.  In fact, most zd1211rw patches have been mirrored
> directly to this driver for some time.  I considered merely updating
> the existing driver with this code, but I think it is more prudent to
> include this as a separate driver just to avoid confusion.  There is
> some symbol clash between the two drivers, so I add a Kconfig hack
> to ensure that only one or the other is built-in or that this one is
> built as a module.
> 
> The maintainers have identified some (IMHO minor) issues with the
> mac80211 port of this driver.  Some of them are summarized here:
> 
> 	http://linuxwireless.org/en/users/Drivers/zd1211rw/mac80211Issues
> 
> Still, I think we would be better-off having this driver upstream.

Agreed, merged into net-2.6.24, thanks John.
