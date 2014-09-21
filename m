From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v7 ethtool 2/2] ethtool: Support for configurable RSS
 hash key
Date: Sun, 21 Sep 2014 23:38:10 +0100
Message-ID: <1411339090.20019.28.camel@decadent.org.uk>
References: <1406031667-30364-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <7ea09e91-8845-4e2a-b69a-3796b0825664@CMEXHTCAS1.ad.emulex.com>
	 <1411332751.20019.24.camel@decadent.org.uk>
	 <1411337728.20019.26.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OxGYXqFIHdARPwNCz+/J"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33304 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbaIUWiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 18:38:22 -0400
In-Reply-To: <1411337728.20019.26.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OxGYXqFIHdARPwNCz+/J
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-09-21 at 23:15 +0100, Ben Hutchings wrote:
> On Sun, 2014-09-21 at 21:52 +0100, Ben Hutchings wrote:
> > On Tue, 2014-07-22 at 17:51 +0530, Venkat Duvvuru wrote:
> > > This ethtool patch will primarily implement the parser for the option=
s provided
> > > by the user for get and set rxfh before invoking the ioctl.
> > > This patch also has
> > > 1. Ethtool man page changes which describes the Usage of
> > >    get and set rxfh options.
> > > 2. Test cases for get and set rxfh in test-cmdline.c
> > >=20
> > > Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> > [...]
> >=20
> > FAIL: test-cmdline
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > E: ethtool --rxfh devname hkey foo returns 0
> > E: ethtool -X devname hkey foo returns 0
> >=20
> > The problem with these test cases is we can't parse the hash key (and
> > reject "foo") until after we start sending ioctls.  test-cmdline doesn'=
t
> > include any mocking of ioctls, but instead makes each test successful i=
f
> > it calls an ioctl.
>=20
> It also doesn't work for me with an older kernel version (I tested on
> Linux 3.14).  I don't know why that is, as your fallback code does look
> reasonable.

Oops, I tested the previous version of this on 3.14.  The latest version
does work correctly.

I'll apply your changes and then disable the two failing test cases for
now.  Thanks for persisting with this.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camu=
s

--=-OxGYXqFIHdARPwNCz+/J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVB9TV+e/yOyVhhEJAQq61Q//axik19TP1Qdi1fzeyye3Gh4yhwceqAIS
gH/S/3lTH/Pm3R4GRP/RbPivXy5/0D6irhxYBDlJmjb9J1Ggl1jTfW5sK4vv1mGe
P4Ztkj3KkB2lMaBKmBdToAjHxQ8eAaX396TJu17LzwzSD1o9gtEpXwgMNPXLvHWV
MPui/mqJnkLsgcNXAj2JSxykf0G3I4iIZd9RWNZJFe++f4D7GKOLRxtnSbBLv9W2
0CQyR986opsZtJVsFrqbCU5Pix0bSi9OLexV5F1flQlGyXMAmJO/uj3HL/yr1xdn
g6yYsCreOjEHutNeFnDn1+RBFv06pKSQ576V7wKdFI9mobcSggiRDaEkb3MGhb2/
aqMXeKzvWinalZdraPtYOxOnRAstExEcHXc8MfzFcUgbT9EL8bHIGjO/QVXV9zo/
49B7bYDAN1uBuAKtKW6aJwyTOBtAJ6KfsNOba5RqbuA76sgCFDFfWCfFnaAdCfxd
e/AfSmBi81idQp2mx/MWEMtHGKiBUNUJmEl5vEkVQF2d0pjmdohbkd+I+ccn2MKw
Df7F2FbQI4FU6zZPpbrPafVr5ddas1LpN2Lq8MxRL/lL6litAXG+4gTxh3/m4cTg
bxijwoBmjzHnv8RKXivrV8EdKPLzWo1JMjKNr57cbB2Uv1BSeioHOJbj9iDnbWde
tUlLxGHFoAw=
=Eut/
-----END PGP SIGNATURE-----

--=-OxGYXqFIHdARPwNCz+/J--
