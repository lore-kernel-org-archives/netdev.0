From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 19:42:53 +0800
Message-ID: <CACVXFVO13tG606nDHth5rEA9jexj1iFHnry5ktrMpm_aGGTSvw@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
	<87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	<87ppy1wfhq.fsf@nemi.mork.no>
	<CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ@mail.gmail.com>
	<87hajdwefp.fsf@nemi.mork.no>
	<CACVXFVO+QZ+mtdOFuNuh+8HQOMcuQrKJRAaW9ohyrMCMeZXsjQ@mail.gmail.com>
	<87d2u1wci6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87d2u1wci6.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 7:08 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>
> The docs for usb_submit_urb() in drivers/usb/core/urb.c lists some
> possible mem_flags use cases. Among these are (where (b) and (c) are
> cases needing GFP_ATOMIC and not applicable here):
>
> <quote>
>  *  (3) If you use a kernel thread with a network driver you must use
>  *      GFP_NOIO, unless (b) or (c) apply;
> </quote>
>
> Is this example
>  a) wrong, or
>  b) not applicable, or
>  c) to be excluded from the new API?

IMO, it may be a) or b), and we can find many GFP_KERNEL usage
inside usbnet(kevent(), ...).

Also (3) doesn't explain the cause. Oliver, could you give a hit?

Wrt. usbnet, except for in xmit & receive handler, the rule should be
same with other usb driver.

Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
