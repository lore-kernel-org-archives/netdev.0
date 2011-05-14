From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Sat, 14 May 2011 12:46:09 +0200
Message-ID: <BANLkTik7s2LG+-ow414VGLALFmk_fEngNQ@mail.gmail.com>
References: <Pine.LNX.4.44L0.1105121025360.1917-100000@iolanthe.rowland.org> <201105141201.40265.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105141201.40265.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2011/5/14 Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>:
> Am Donnerstag, 12. Mai 2011, 16:37:28 schrieb Alan Stern:
>> Therefore usbnet's poll routine should take the "weight" argument as=
 an
>> indication of how many outstanding rx URBs are allowed. =C2=A0Each t=
ime the
>> poll routine is called, it should check to see if any rx URBs have
>> completed since the previous poll. =C2=A0If not then there is no net=
work
>> traffic, so usbnet can take itself out of the poll loop. =C2=A0Other=
wise,
>> the number of outstanding URBs should be adjusted (by unlinking some=
 or
>> submitting more -- subject to some fixed maximum limit) to match the
>> new "weight".
> What does happen if we reach the weight 0 ?

Poll callback won't be called with weight 0. If there are more RX
packets after processing 'weight' of them, then the callback will be
called again later.

Best Regards,
Micha=C5=82 Miros=C5=82aw
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
