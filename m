From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 16:07:55 +0800
Message-ID: <CACVXFVPDV5v3gW5wz44kBsXm0KreHJnkvoxEPZhnLVoaTDw-Yw@mail.gmail.com>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
	<201206180923.36091.oneukum@suse.de>
	<CA+v9cxZG6b1O7kOQpeTELtv0vHzqy-8NH84boMpim0BM+tp1eQ@mail.gmail.com>
	<201206201000.21845.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206201000.21845.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 20, 2012 at 4:00 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
> Very well, on second thought, this patch makes sense.
> Could you resend and I'll ack?

BTW, maybe it is better to add below

    usbnet_defer_kevent(dev, EVENT_STS_HALT);

for -EPIPE returned from usb_urb_submit if it will be resent.

thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
