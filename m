From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Fri, 05 Mar 2010 00:02:21 +0000
Message-ID: <1267747341.2819.177.camel@localhost>
References: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CxUpAMNuZXGXg76DLMyA"
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33952 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753836Ab0CEAC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 19:02:27 -0500
In-Reply-To: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CxUpAMNuZXGXg76DLMyA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-10-25 at 11:10 +0900, Ken Kawasaki wrote:
> Hi,
>=20
> >> > Random question: are CIS files copyrightable? =20
> >>=20
> >> The CIS contains the IRQ, ioport-range, voltage information etc
> >> like the PCI config space.
> >> So I think it is not copyrightable.
> >> but Sierra Wireless provided this CIS by GPL.
> >[...]
>=20
> >If it is subject to copyright - which apparently they think it is - then
> >when redistributing under GPL we must be able to provide the 'preferred
> >form for modification'.  So that leads to the question, is this blob or
> >hex file the preferred form?
>=20
>=20
> (1)The CIS contains data only,
>     does not contain the code to be executed.
> (2)Sierra Wireless provided the binary of the CIS only.
> (3)These CIS are stable and does not need to be modified.
> (3)The content of the CIS can be seen by the dump_cis utility.
>=20
> So if someone want to modify the CIS , I think it is OK
> to use hex editor.

The CIS files under firmware/ are, according to firmware/WHENCE,
'developed by the pcmcia-cs project'.  So I had a look at what's left of
the pcmcia-cs project and its last release, and found that it includes:

- the tool 'pack_cis' which compiles a text version of CIS to the
  standard binary format
- text versions of most of the CIS files

Since the text versions contain comments which are excluded from the
binary format, I believe they should be considered the 'preferred form
for modification' and included in the linux-2.6 and linux-firmware trees
along with the binaries.

Ben.

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-CxUpAMNuZXGXg76DLMyA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS5BKCee/yOyVhhEJAQKfQQ//TNi5I5hlFQBfIX2iPELnbJjoTgPvVZT4
JROTv/6pplY+F+JMhJlHgemTT9bSgtvsOjW6sJLbDU+uNSHBkE/rnFCGsFzbpVg5
9AvU1Qj6b+clXdjXPW8kQiyn8jbxaGKtoAHLBUa2NWK5098rvUlMap/pu9TOZGNa
RNYhWt4iV3MzyySvh8/6N3zmpz55Cv7Idqjxd/olbZciiTVfi4KOdoS+9NwPi5jW
1yXCUD0q5GpqSuFVeapqv3Fjs5hSHQy9S6RD3p/ri+9eKCwUWrTcwxgIA+Ae81sz
Tbk3jDnrq3/az4YfHcTMc8s9HZGQ38VH9PNAW/D472SdeBYX5qp5xba/bYOGNznE
ZbUKwNGgW5KiRUlK8QRPQAwOcI2o1Ihn5ENyeKHO90L6vKTVCYy9Wm2iVIXQb4u0
my7OTgAZG7RkvxGHf5FwrBJVXmEQpHJ+6GLgUexZKHPdOJmkq6dO/dp5tXzXG0oV
kVS6WPfY73FFzxmuxaJ2bdQw1qw9EOuQVoy2CaukAY7prH9aNA9OuWOKllOw/klo
IoZXH+qFpSx5GUAGkMg29I6/eohaMDHlASoMmtKOGINpQNW9djiK6WrxkCKmZUpa
t6vR6mjEF9+yKb/Ppf2N0wjYDHSgbJKvv1pLlIQiUofKc6nEVdES3rfATPVqloUV
XbAl11sOtdQ=
=7dSg
-----END PGP SIGNATURE-----

--=-CxUpAMNuZXGXg76DLMyA--
