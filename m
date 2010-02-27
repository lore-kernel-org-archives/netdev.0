From: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
	drivers
Date: Sun, 28 Feb 2010 03:38:20 +0900
Message-ID: <20100228033800N.fujita.tomonori@lab.ntt.co.jp>
References: <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
	<20100227.015350.71138134.davem@davemloft.net>
	<51f3faa71002270959o4d1435e3xf67185fccaf50b18@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51f3faa71002270959o4d1435e3xf67185fccaf50b18-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 27 Feb 2010 11:59:47 -0600
Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Sat, Feb 27, 2010 at 3:53 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> w=
rote:
> > From: Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date: Fri, 26 Feb 2010 21:08:04 -0600
> >
> >> That seems like a reasonable approach to me. Only question is how =
to
> >> implement the check for DMA_64BIT. Can we just check page_to_phys =
on
> >> each of the pages in the skb to see if it's > 0xffffffff ? Are the=
re
> >> any architectures where it's more complicated than that?
> >
> > On almost every platform it's "more complicated than that".
> >
> > This is the whole issue. =A0What matters is the final DMA address a=
nd
> > since we have IOMMUs and the like, it is absolutely not tenable to
> > solve this by checking physical address attributes.
>=20
> Yeah, physical address isn't quite right. There is a precedent for

Probably, you need to check PCI_DMA_BUS_IS_PHYS.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
