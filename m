From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/29] wimax: headers for kernel API and user space
	interaction
Date: Tue, 09 Dec 2008 00:29:54 +0100
Message-ID: <1228778994.22164.159.camel@johannes.berg>
References: <cover.1228759689.git.inaky@linux.intel.com>
	 <b0c3e76927519e8e46f9de8927207257159a70f0.1228759689.git.inaky@linux.intel.com>
	 <1228766734.22164.127.camel@johannes.berg>
	 <200812081322.14089.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sWftUloK9/5IRq5CQnva"
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34663 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYLHXac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 18:30:32 -0500
In-Reply-To: <200812081322.14089.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sWftUloK9/5IRq5CQnva
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-12-08 at 13:22 -0800, Inaky Perez-Gonzalez wrote:

> I am paying attention to what you say :)=20

:)

> I don't want to have this iwpriv like thing for ever; remember that is an=
 stop
> gap for the time being as (a) we have no other reference hardware and (b)
> our user space is still evolving.
>=20
> We already started discussing in the wimax list (with Juuso, from Nokia) =
how
> a NAP-based API should look. My plan is to start working on it in the New
> Year, after I come back from vacation.

Good to hear. I'm a bit worried about the pain of removing an API again
on such short notice, but I guess you'll have to deal with that. Unless
you'd want to wait until you've figured it out, it's only another kernel
release without wimax that way... ;)

> > identical to netlink attributes, but just a bit different:
> > > + * This is the control protocol used by the host to control the i240=
0m
> > > + * device (scan, connect, disconnect...). This is sent to / received
> > > + * as control frames. These frames consist of a header and zero or
> > > + * more TLVs with information. We call each control frame a "message=
".
> >
> > Or isn't that what is contained in the WIMAX_GNL_MSG_DATA attribute? Yo=
u
> > can nest netlink attributes, that would already make it a whole lot mor=
e
> > regular, rather than defining your own sub-protocol.
>=20
> It is, but that is host-to-device (or better, host-to-firmware protocol),=
 the
> device's specific protocol. I have no say on how it is. It is quite simil=
ar,
> in any case, as it is TLV based.
>=20
> When the kernel level API is in place, a command sent over generic netlin=
k=20
> will be translated by the driver into a protocol-specific message and sen=
t
> to the device.

Sounds great.

johannes

--=-sWftUloK9/5IRq5CQnva
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJPa3uAAoJEKVg1VMiehFYYRgP/AnCqZTLw3X/ooZXNjhW4IMP
K4ZU5ktTK4iM5J8DRIFkWfb2D7Tq8vf8K1PhFNm2O/bTMUgIxXAiDhsBP7aKU/cO
HRqWcND/8f3/XVlEylH0x7/lNWobmnjHGXRh79RpQR2JRXEp/n4PMyjV0UG/B46P
TrQ9TQ7bV7Cr96T717umKhE/otxpWBt9BTyxS5Jj7rQCAs1vAm4C2El5O4jQ9yYo
bShcoDa2PvEdfEaQkp4WQ7+728xnivZN80d1WSKorEi1XdPao7Ry/Ov7mfohQT8B
hiPxF79S8PaFl0f769UOHPvALVLAOkIU1GujaDdXpRed3BprQ2BvBWYlE3tw/wEG
eWZ5RqHvyOm8+SSMDH0A+5d7413UcpkZUlnss+ey007IpUmN0zwM34CuPcWDT/f7
Tm45b4STcNtWVrZ+we3NNt1uTl+JRSopL3BkwYmEVk/argTUfudcLv6lR9iSBEiK
tgRxSAP1kYY1cyQd9lhKJpT6Cmbyz38VmyHF9cWY+gQJtvWsO6/eSDM41QfP566C
BvurwhmOgjiWwHht2CqLhbMCyPo43+Mf5kyZqCwA+JvyoH+45cBa9p1QcZOzqiAz
Edb5jk69NtNSbjP589Y+7B0Ckoqc6ZUoAzT4IRYV7+fXVEwtH8aPH3hEX//mpqYi
1il1KHqr7QlDkpsyF1dR
=+KfY
-----END PGP SIGNATURE-----

--=-sWftUloK9/5IRq5CQnva--

