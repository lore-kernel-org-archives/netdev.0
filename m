From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Porting ethernet over spi driver (powerline device)
Date: Sat, 26 Apr 2014 14:45:21 +0100
Message-ID: <1398519921.7767.220.camel@deadeye.wl.decadent.org.uk>
References: <5350ED9E.6080103@lategoodbye.de>
		 <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>
		 <53563E3C.3030108@i2se.com>
	 <1398180075.3624.191.camel@deadeye.wl.decadent.org.uk>
	 <535A0DC9.8060102@i2se.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s0CaAcsxfKqPZeVghhQw"
Cc: Stefan Wahren <info@lategoodbye.de>, netdev@vger.kernel.org,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38414 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbaDZNpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 09:45:31 -0400
In-Reply-To: <535A0DC9.8060102@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s0CaAcsxfKqPZeVghhQw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-25 at 09:24 +0200, Stefan Wahren wrote:
> Am 22.04.2014 17:21, schrieb Ben Hutchings:
> > On Tue, 2014-04-22 at 12:02 +0200, Stefan Wahren wrote:
> >> Am 22.04.2014 04:22, schrieb Ben Hutchings:
> > [..]
> >>> Most of the interesting new features are related to multiqueue and
> >>> protocol offloads that I wouldn't expect to exist in an SPI-attached
> >>> Ethernet controller. =20
> >> You are right.
> >>
> >> Btw, is simple power management (suspend, resume) a must-have feature?
> > If you're intending to get the driver in-tree, I don't think those are
> > an absolute requirement but I would certainly recommend implementing
> > them.
> >
> > Ben.
> >
>=20
> Yes, that's my intension. The QCA7000 isn't a typical ethernet over spi
> device, it's a serial-to-powerline bridge. Acting like a ethernet over
> spi device simplifies the implementation. This leads to an important
> question.
>=20
> Should the QCA7000 be handled strict as an ethernet device or a little
> bit more distinguished as a powerline device?
[...]

If it uses Ethernet framing, supports multicast/broadcast, etc. then I
don't think there's any need to distinguish it.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-s0CaAcsxfKqPZeVghhQw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1u4cee/yOyVhhEJAQrLEw/+JQBsxWe6ZeMdRC+s8jG2ms0oqbtA+3Ow
gwe2F4Mw7gJzaJ5k40e+N3ov8PXLUc2PxaoWsRoV2ypVplMF3L6l09xO+Kh4UCzO
YBKgmXsuWprKYhPwy73x7zmEhVYPvcxL94aD0uGro0YuLKpqA6zqHjlKsDr+2L7v
ZSmh9ccyt8//EqI0mh+oBOdRZD6RY5lm/7eXY3WWz/+GUFD4QzImow2mK6S2jvGi
ddcOwsrGkVZ6RRmIRmHoy0yTN2AkxkPLaZpIwyk/BIG40N0PLktrlXC0jGhAY+dd
3DhKdx1Xh84x1w+Za/p3FZo95GDy47A4BsvCmJyHZov00dJAAMkuLVUJz/xTjTgs
7tNrCc3wr9wgcbO2NLI0SxqeIqK8lXsxwNJMow5gTnau1MUUGUgXGVGU5A+piuSR
ORuHGucEUtJl37ToGMlH9hr/IUfZOR95EUf05Hcn06pXXW0q46Jymfc3mrMiQv4U
0Y3JUVmrfRnjv6QG1E31Rfq4gP6eGvVmW8TrFRsjysNt/k3pcsVCs/UWHH2BUI8i
cFnk2/fetlqLtqwNUcLh6dl7sO/jkRI4CTD84k/OJar2SKMyQsJDbZ9sXj1qNNXp
simM7gjbr5FJEOXWSGtBq8gAFlIjhegaXDbiLDpEt5UX+SYVA1OkOVw9HKGfMvlA
WRPRMXloo9Q=
=hXLF
-----END PGP SIGNATURE-----

--=-s0CaAcsxfKqPZeVghhQw--
