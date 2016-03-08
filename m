From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] cdc_ncm: do not call usbnet_link_change from
 cdc_ncm_bind
Date: Tue, 08 Mar 2016 20:37:08 +0000
Message-ID: <1457469428.27389.8.camel@decadent.org.uk>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	 <20160307.141100.1511700720120062677.davem@davemloft.net>
	 <CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	 <20160307.145406.188091362181073486.davem@davemloft.net>
	 <87k2le815w.fsf_-_@nemi.mork.no>
	 <CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw@mail.gmail.com>
	 <871t7k7mgo.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qFVCe8YZdAWlZovMcb/O"
Cc: David Miller <davem@davemloft.net>,
	Andrey Konovalov <andreyknvl@gmail.com>,
	Oliver Neukum <oneukum@suse.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49261 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867AbcCHUhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:37:23 -0500
In-Reply-To: <871t7k7mgo.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qFVCe8YZdAWlZovMcb/O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-08 at 21:18 +0100, Bj=C3=B8rn Mork wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>=20
> >=20
> > So looking at this, I wonder...
> >=20
> > Why is that FLAG_LINK_INTR thing not just always used?
> >=20
> > The _only_ thing that FLAG_LINK_INTR does is to cause
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0usbnet_link_change(dev,=
 0, 0);
> >=20
> > to be called after network device attach. That doesn't seem to be contr=
oversial.
> Not all usbnet drivers support carrier detection, which is required to
> ever bring the link up again.
>=20
> >=20
> > Looking at some examples, we have ax88179_178a.c that doesn't set the
> > flag, but instead does that usbnet_link_change() call at the end of
> > ax88179_bind().
> >=20
> > There are a few drivers that seem to never call that
> > usbnet_link_change() at all, and don't have that FLAG_LINK_INTR flag.
> > Would they break?
> Yes.=C2=A0=C2=A0Drivers without carrier detection will be "down" forever.
>=20
> >=20
> > Why is it called "FLAG_LINK_INTR" anyway? There doesn't seem to be
> > anything "INTR" about it.
> Beats me.=C2=A0=C2=A0I can only say that I always find naming difficult..=
.
> We could ask Ben, who introduced it in:
[...]

It is supposed to imply that the device generates link-change
interrupts. =C2=A0Of course it is also possible for a device driver to
satisfy the requirement by polling the link state.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-qFVCe8YZdAWlZovMcb/O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3zf0AAoJEOe/yOyVhhEJwroQAJStIZoCUHlhn04JxtfkWL9f
LzaSv7UcbhQff+JdrM7kUu09QRVsfE/CQRXb+JlR+aYG0MResGc/Ab1aqyEnvpKQ
XnYtIdYGu+wlxIA+Yw8wDIVCwP64XjPpRPB9vWFcDhSMsrCEhFBi+XlDv8r0M6Tn
41OaE/LDHjkzfKy80ODjJmcZ86BuBeC3ezVPk02yTLB17ECz5oNO7QXLJ3A3rAMF
pOfZpy8n2wimnRN4OE06wRsAas0DR1xm6Jhce26ecOo0i4opOvdvouxWDK7DCUmn
xP8f/ZHLKfp9BEmSs11tlhGyzKMehANjgdw2SRJr4TQ3GmcxgHAvCzj/BWRi/Umv
R7RKcDrBfa4nYi4fxnTTnrNZf9Uzf6qOmEAjBcCAEi88UW1elXKQMpN/mg/+9mWy
J3g0zEQfK6fAtKhGdvBIFNkF/nI/CrOivzbIxp0QHduZMqFnxQ5FKzCDoCzUCEbq
KkDbEYKz3i2w4fDUUxWLL5a3WK1bKkafo6AJXon2RjcfI1eoIFalBv8ZGCSQnvo8
3Ocwd9eMBb1/xjto/ScgkvOd6AoP6Up5Aw/17sVUhT9pCqGCLk2lDmBaJZWbWak9
dT0z0viT0aWRhlLQz7aGv2nXoUSV/gfIgyrLXicLAvKVhyYv28wKHmG/zy5UksyG
KAfhUCKxGFUK+b1Y5T8C
=DBhU
-----END PGP SIGNATURE-----

--=-qFVCe8YZdAWlZovMcb/O--
