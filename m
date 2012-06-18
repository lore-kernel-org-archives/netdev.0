From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Mon, 18 Jun 2012 09:23:36 +0200
Message-ID: <201206180923.36091.oneukum@suse.de>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com> <20120617.163017.1067800063889498786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120617.163017.1067800063889498786.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 18. Juni 2012, 01:30:17 schrieb David Miller:
> From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 13 Jun 2012 20:50:31 +0800
> 
> > intr_complete() submits URB even the interrupt endpoint stalls.
> > This patch will try to activate the endpoint once the exception
> > occurs, and then re-submit the URB if the endpoint works again.
> > 
> > Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Review from USB experts would be appreciated.

The code implements a minimum error handler correctly.
Did you observe a stall in actual hardware or is this a just
in case patch?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
