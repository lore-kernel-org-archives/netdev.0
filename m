From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Mon, 9 May 2011 11:26:04 +0800
Message-ID: <BANLkTimXmHr8aJ7WgRVvZj85t-gw68C_Ww@mail.gmail.com>
References: <201105062045.37336.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105062045.37336.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

2011/5/7 Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>:
> Hi,
>
> I'd like to get a feeling what people are working out there regarding usbnet.
> So please, if you do something, or think something ought to be done, please
> speak up now.
>
> IMHO usbnet needs better support for
>
> - batching protocols
> - double buffering on the rx path
>
> with the latter having higher priority.
>
> Coments?

Maybe another thing about rx should be considered too: we should introduce
one flow control mechanism into rx path so that too much coming packets can
not consume many of memory and cause out of memory for atomic allocation.

Current implementation has such kind of risk certainly, as i explained in the
patch with title below:

       usbnet: runtime pm: fix out of memory

thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
