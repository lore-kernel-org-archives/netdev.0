From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Teach pegasus driver to ignore bluetoother adapters
 with clashing Vendor:Product IDs
Date: Tue, 13 Oct 2009 00:31:10 -0700 (PDT)
Message-ID: <20091013.003110.187457721.davem@davemloft.net>
References: <910710.29413.qm@web52911.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rankincj-/E1597aS9LQAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <910710.29413.qm-7brg08ZX0I2B9c0Qi4KiSl5cfvJIxWXgQQ4Iyu8u01E@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Chris Rankin <rankincj-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date: Sun, 11 Oct 2009 06:57:50 -0700 (PDT)

> I submitted this patch months ago and then forgot about it, but I've
> noticed that it hasn't been picked up so I've regenerated it against
> 2.6.31.
> 
> Short description:
> 
> The Belkin F8T012xx1 bluetooth adaptor has the same vendor and product
> IDs as the Belkin F5D5050, so we need to teach the pegasus driver to
> ignore adaptors belonging to the "Wireless" class 0xE0. For this one
> case anyway, seeing as pegasus is a driver for "Wired" adaptors.

Applied, but please put your Signed-off-by: here at the end
of your commit message rather than after the patch.

Putting it after the patch makes it more difficult for
automated tools to pick it up, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
