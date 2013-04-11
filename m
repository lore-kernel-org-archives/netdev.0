From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 13:54:08 +0200
Message-ID: <1762413.DH0n5NjUdu@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <87d2u1wci6.fsf@nemi.mork.no> <CACVXFVO13tG606nDHth5rEA9jexj1iFHnry5ktrMpm_aGGTSvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVO13tG606nDHth5rEA9jexj1iFHnry5ktrMpm_aGGTSvw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 11 April 2013 19:42:53 Ming Lei wrote:
> On Thu, Apr 11, 2013 at 7:08 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> >
> > The docs for usb_submit_urb() in drivers/usb/core/urb.c lists some
> > possible mem_flags use cases. Among these are (where (b) and (c) ar=
e
> > cases needing GFP_ATOMIC and not applicable here):
> >
> > <quote>
> >  *  (3) If you use a kernel thread with a network driver you must u=
se
> >  *      GFP_NOIO, unless (b) or (c) apply;
> > </quote>
> >
> > Is this example
> >  a) wrong, or
> >  b) not applicable, or
> >  c) to be excluded from the new API?
>=20
> IMO, it may be a) or b), and we can find many GFP_KERNEL usage
> inside usbnet(kevent(), ...).

Only in the rx path.

> Also (3) doesn't explain the cause. Oliver, could you give a hit?

IIRC this was to cover networked file systems.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
