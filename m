From: Li RongQing <roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] Lockdep splat in usb network gadget
Date: Wed, 23 Jul 2014 17:21:50 +0800
Message-ID: <CAJFZqHw+FY-t6_4urxv8PRFNvsJjMBOzRmiaZnf81RJ8tNV_Qg@mail.gmail.com>
References: <alpine.DEB.2.10.1407181542290.24854@nanos>
	<CAJFZqHys3KUxBBaV18Gb3h-R7tQQpZJyh92dR1tyNizgoT5=UQ@mail.gmail.com>
	<alpine.DEB.2.10.1407231110490.23352@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeff.westfahl-acOepvfBmUk@public.gmane.org
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.10.1407231110490.23352@nanos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 5:11 PM, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org> wrote:
>
> So what's the fix?


revert it, I think netif_stop_queue() did not free the resources, so
this commit does not
fix anything;  if no one objects, I will send a patch to revert it.

-Roy
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
