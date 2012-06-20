From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 10:00:21 +0200
Message-ID: <201206201000.21845.oneukum@suse.de>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com> <201206180923.36091.oneukum@suse.de> <CA+v9cxZG6b1O7kOQpeTELtv0vHzqy-8NH84boMpim0BM+tp1eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxZG6b1O7kOQpeTELtv0vHzqy-8NH84boMpim0BM+tp1eQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 18. Juni 2012, 18:25:15 schrieb Huajun Li:
> On Mon, Jun 18, 2012 at 3:23 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> > Am Montag, 18. Juni 2012, 01:30:17 schrieb David Miller:
> >> From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Date: Wed, 13 Jun 2012 20:50:31 +0800
> >>
> >> > intr_complete() submits URB even the interrupt endpoint stalls.
> >> > This patch will try to activate the endpoint once the exception
> >> > occurs, and then re-submit the URB if the endpoint works again.
> >> >
> >> > Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >>
> >> Review from USB experts would be appreciated.
> >
> > The code implements a minimum error handler correctly.
> > Did you observe a stall in actual hardware or is this a just
> > in case patch?
> >
> 
> This one is just a patch, thanks for your comments.

Very well, on second thought, this patch makes sense.
Could you resend and I'll ack?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
