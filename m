From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.0.8 kernel : NULL ptr deref in skb_queue_purge()
Date: Thu, 8 Dec 2011 10:02:08 -0800
Message-ID: <20111208180208.GA16883@kroah.com>
References: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2011 at 02:40:49PM -0800, Grant Grundler wrote:
> Hi,
> I'm testing asix (USB 100BT ethernet adapter with AX88772) driver
> initialization (and shut down) paths and reproduced a
> "skb_queue_purge" panic 3 times after a few hundred/thousand
> iterations of rmmod/modprobe. I'm inclined to believe
> skb_queue_purge() is a victim and not a culprit here.
> 
>  I don't know if all 3 "spontaneous reboots" I've seen have the same
> stack trace as the one I have a record for:

Have you tried this on 3.1, and especially, 3.2-rc?  A number of asix
patches have gone into the 3.2-rc series, perhaps they might have
resolved this problem already?

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
