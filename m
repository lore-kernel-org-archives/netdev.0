From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Mon, 9 May 2011 23:22:24 +0800
Message-ID: <BANLkTi=AGQyvG58n9FG2Axbz7Ue8a6E3kg@mail.gmail.com>
References: <201105062045.37336.oliver@neukum.org>
	<BANLkTimXmHr8aJ7WgRVvZj85t-gw68C_Ww@mail.gmail.com>
	<201105091042.01014.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105091042.01014.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

2011/5/9 Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>:

> Do we really need to avoid it, or do we just need to recover?
> If avoidance is needed, should we use NAPI?

IMO, OOM can recover it certainly but with much cost, so we should
avoid the case. I don't think NAPI can avoid it, because NAPI will
cause skb to be allocated without any limit if there are packets
coming, still no chance left for usbnet_bh to handle and free these
SKBs.


thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
