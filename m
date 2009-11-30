From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 12:46:25 +0000
Message-ID: <1259585185.3709.181.camel@localhost>
References: <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
	 <20091129.003024.245104886.davem@davemloft.net>
	 <20091130065512.GA2792@jenkins.domain_not_set.invalid>
	 <20091129.230703.206229796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-9U9u19Xg8pGJihmx4FFC"
Cc: brandon@ifup.org, grundler@google.com, tobias@ringis.se,
	kyle@mcmartin.ca, netdev@vger.kernel.org, grundler@parisc-linux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60043 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753389AbZK3Mqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 07:46:31 -0500
In-Reply-To: <20091129.230703.206229796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9U9u19Xg8pGJihmx4FFC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-11-29 at 23:07 -0800, David Miller wrote:
> From: Brandon Philips <brandon@ifup.org>
> Date: Sun, 29 Nov 2009 22:55:12 -0800
>=20
> > Thus, the patch only lets tulip handle 0x9100 and 0x9102 if __sparc__.
> >=20
> > Perhaps someone knows if there is a way to tell the PCI card from the
> > sparc builtin machine?
>=20
> We should get both cases working in one of the two drivers,
> preferrably Tulip.
>=20
> That's the outcome I'm trying to say is the only legitimate one.

If the problem is that the drivers are not portable, then this makes
sense.  However, as I understand it, the problem is that the same device
ids have been assigned to significantly different controllers/boards.
In this case it may be better for both of the drivers to claim the
device ids and to distinguish them at probe time.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-9U9u19Xg8pGJihmx4FFC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASxO+nOe/yOyVhhEJAQKPrRAAqnEyoQzTyhuUD+ScFCMluj4f8aZNgoHF
QitcXk18m+4wIZJkK5JHngtEE/A7QJxW/v6YWWQJi6kVphIB4BK5aAxjTS021SK3
s3DzZFvNUZ3SsPlkVKSa4L+QDT7YN6nVaH++EuSK0IsoSDYdVD21rHIzsAICcWCI
DFNXRPvvyWZz7q5YZu7pzoZqRPttzBbulce/t/ckiKYO+FwvxqrcpXkWI4QedFOo
VcHyK/lCnMKwCeoO451WgI0O67JXevbev0IgiuZYBgX45oCWJVfA4QUT21ykxrzb
GjBybPYobuSME8Z+SkMqCMr9Rj9w02M5BrLsxgwxuIHuhx90Uj7CgmW6eu2POdE3
Y5t7xyiHpxY1L4ENwi8DIzIalD2tUzwBuG3FgxetWsDfUMfIlN0oZ/yhGEDDQC4l
znGq+ebsMsa67w9DEdBRBIzDB4UcfTVuUh6pawbXZB0/e3p/8kbRqG59bCOd25jP
bkRRUi/DpAkHWX1TdWB9oEkhvdtqiLrziQg5W5aXEt6NCFp1nUaKnivWAfz/juMM
EtsA7J8cyC0uNGPZXMW2Vye5daLD8Fmdgd3rc/ECJJxAoQBURKRkIiBXVhqtUrrL
CDyhlqnyO+VNmke+sDakyWwdRaisqZwz1no5M2J842tbH42Hqy2C9oXMZ99BKPuZ
yKBwlf4xi6g=
=Va2e
-----END PGP SIGNATURE-----

--=-9U9u19Xg8pGJihmx4FFC--
