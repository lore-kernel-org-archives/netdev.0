From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: OOPS bug KERNEL LINUX- Version 2.6.26
Date: Mon, 22 Sep 2008 18:27:16 -0400
Message-ID: <20080922222716.GI3660@tuxdriver.com>
References: <K7M9ZI$69A44BBF23D86D612A80B0EA98EEEE6B@libero.it> <20080922.151635.200306286.davem@davemloft.net> <200809230025.03680.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, andrea_monta-e7mAqy1nzl5eoWH0uzbU5w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200809230025.03680.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 23, 2008 at 12:25:03AM +0200, Ivo van Doorn wrote:
> Hi,
> 
> > > 1. Problem with usb-wireless-key 
> > > 2. I can't find my device typing ifconfig -a or iwconfig I don't find any wireless attached device. But I have my usb wireless connected. A belkin usb wireless key.Before, with the kernel 2.6.25 all worked well
> > > 3. nothing
> > > 4. Linux version 2.6.26 (root@clementino) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 PREEMPT Mon Sep 22 15:57:45 CEST 2008
> > > 5.
> 
> You missed the message from rt2x00 2 lines above this trace, which undoubtly have said something like:
> 	"Invalid RT chipset detected."
> which is triggered when rt73usb is loaded for a device it does not support
> 
> The current workaround for this issue is blacklisting rt73usb and making sure the driver
> which is required for your driver is loaded instead.
> 
> I'll look into the reason why this actually triggers a NULL pointer, since that is obviously a nasty bug.

-stable needs a patch similar to the one here:

	http://people.redhat.com/linville/kernels/rhel5/patches/jwltest-rt2x00lib-probe-fail.patch

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
