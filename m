From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not
 interacting well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 13:42:49 +0100
Message-ID: <1305031369.4065.259.camel@localhost>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	 <1304995124.4065.157.camel@localhost>  <20110510043833.GG6397@morgul.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-teHZnm23nUG9XaYYZRDG"
Cc: 625914@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Noah Meyerhans <noahm@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56839 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751413Ab1EJMnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 08:43:00 -0400
In-Reply-To: <20110510043833.GG6397@morgul.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-teHZnm23nUG9XaYYZRDG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-05-09 at 21:38 -0700, Noah Meyerhans wrote:
> On Tue, May 10, 2011 at 03:38:44AM +0100, Ben Hutchings wrote:
> > This is pretty weird.  Debian version 2.6.38-3 has a few bridging
> > changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like the=
y
> > would cause this.
>=20
> I have apparently filed the bug against the wrong version of Debian's
> kernel.  2.6.38-3 is not affected, and works as expected.  The change
> was introduced in -4.  That may have been clear from the report itself,
> but the report was filed against -3.  I've fixed that in the BTS.

I gathered that, and then made the same mistake in writing the above!
The version with the regression, 2.6.38-4, includes the changes from
stable 2.6.38.3 and 2.6.38.4

Ben.

> I've also confirmed that -5 is affected, to no great surprise.
>=20
> I'll investigate further.
>=20
> noah
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-teHZnm23nUG9XaYYZRDG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATckywue/yOyVhhEJAQpq7Q//WUpnvtU9/Ju3QTjshrxT9MbD5gGQ175O
q7J04/W0fD1CmABi1Hi7wciHIvJ4C/dQgnIM7eM0eQoFhuAaV42JWZJCwgZalW1k
jU20WpxETkOjJCqPu9Dhj0HUjxL1+O5e6U6zWAbAAqOvOqdax9ZFGngrPlUOvcgh
ZLE8ZQtQV9+9a3Vp3jhOT8oYK+SAIHgq65RJeot9cXMV3qcoG8UIrE2hWouS15YB
Tjtq4sVs1MSbtPi1N4d61c9EAFUOn6L0/tczbw7b2AMYwhOd0LJ1EoKnZtvZNUvW
pcKbSf9BJ+osXEIiAgh4DV8G+USKdfdno80UkKPN9w6IcLyEaL/124WCszml4V7O
CqKSf3rV2hvAPEA7rY/6JqnEsR/B/H8JMG70Gf4GFJa1u3wIEGziqmF7hXchv+6H
coEDIje+QEXPDRbxUQgyKSPcYFMU3ufd1UZwsrSHMhXxDdZghnLzvmma+GvjSRsr
EYITpZRK1hNVUBFuh8E7zgbaN2Navu6O3UGrlk9VzA/VVU7u04EGI9sLOZGEb+MN
UWaPbuzcfqfUgvr8/F3AXWGd0q0AlK3cSn1CwUwFkDPM5PSpcRb4I8vU2O6+YEOO
EvtfFPz+Qd4FSUaLvkBqP52qPk4bnSUhwx9OXL27MhFI/CbifYCoFBc1SBwi/e8V
IrKEKA1v4hE=
=rkQO
-----END PGP SIGNATURE-----

--=-teHZnm23nUG9XaYYZRDG--
