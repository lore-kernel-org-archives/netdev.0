From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Fri, 6 Aug 2010 03:37:01 -0400
Message-ID: <201008060337.03103.vapier@gentoo.org>
References: <1281076034-17390-1-git-send-email-vapier@gentoo.org> <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5294707.94Cv9g2RA5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38167 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933894Ab0HFHgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 03:36:20 -0400
In-Reply-To: <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart5294707.94Cv9g2RA5
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Friday, August 06, 2010 02:43:46 Changli Gao wrote:
> On Fri, Aug 6, 2010 at 2:27 PM, Mike Frysinger <vapier@gentoo.org> wrote:
> > If the SMSC phy is not built as a module, we get the warning:
> >        drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not
> > used
> >=20
> > So mark the structure as maybe unused to avoid this.
> >=20
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > ---
> >  drivers/net/phy/smsc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> > index 78fa988..11944ef 100644
> > --- a/drivers/net/phy/smsc.c
> > +++ b/drivers/net/phy/smsc.c
> > @@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
> >  module_init(smsc_init);
> >  module_exit(smsc_exit);
> >=20
> > -static struct mdio_device_id smsc_tbl[] =3D {
> > +static __maybe_unused struct mdio_device_id smsc_tbl[] =3D {
> >        { 0x0007c0a0, 0xfffffff0 },
> >        { 0x0007c0b0, 0xfffffff0 },
> >        { 0x0007c0c0, 0xfffffff0 },
>=20
> How about adding a #ifdef CONFIG_SMSC_PHY_MODULE clause  around these
> lines?

--nextPart5294707.94Cv9g2RA5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iQIcBAABAgAGBQJMW7ufAAoJEEFjO5/oN/WBmpUP/1YSgJarsQgHHdeglH5YUg7H
Kg58BoEdOTG/JZGmC3UsN9PaTy+9k+7DotPSgrJEjltWs2xiHugUrHL6qtCzpC63
J6tm1RZyoc0QH6y1wfl+I8ZA6O1LbItBGA2+FpBsSOfzQvVcTuS64He7omug4XEm
XtTDQdolXu79mRbJT0/CFmxThmiH3aAK03YJe1LbQHBkdSe5qBZLLyQLNyeogFc/
OAaN/P5y6RWF3USVpM4vVILYmY9N6QlZKR4lcM5e+UV6ojH64Ww9e2jFA0id8HXN
38qcbSkQfNTUey9RJcDDP3Om7kJzCYebGpdtV8z4RrsXgj1r+FUG3YGdB1JogiMe
htfdP2br2uCWnSqjoe7eerJkVLrsLWE5LjCQLfMDpsk7c4+F1whuqnGkGLnarutz
7/tASmvRG97+yCKUrk8xTfdErXqHxLcbOThEaEv5+gKGZaJA6d2Yd4IwaPa+fUhk
kEShoZXn0GiKzf3R+BU56BebYpLcVVmyp8zOvvw2cyxTqsbqMTGHZDNGrzRK4D3/
K0NK/VN2iJ7eWZ48ZUq+1MQ/qYNDGh15pcQfQ9Sexb28qIkCcwS2oz/HIFvnG3p8
AYGU7/WV4IVYl7DC6N2qF0lbGjCXPaO6tAfkFidOVnrEapLRxLj1YHL9a5MsN87g
balGaYS0emXfHxqnvz4m
=jBl1
-----END PGP SIGNATURE-----

--nextPart5294707.94Cv9g2RA5--
