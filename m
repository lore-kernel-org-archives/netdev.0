From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Add get_eee() and set_eee()
 ethtool support.
Date: Tue, 05 Apr 2016 22:22:45 +0100
Message-ID: <1459891365.24442.4.camel@decadent.org.uk>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
	 <1459844562-24576-6-git-send-email-michael.chan@broadcom.com>
	 <1459850858.23351.45.camel@decadent.org.uk>
	 <CACKFLinJMDC52Bbc_OFQLFAJuoC-DC5kdawkRo1J75Q5v3XOpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zVx9SXO4ZxQrKP+AIEHW"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48196 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbcDEVWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 17:22:53 -0400
In-Reply-To: <CACKFLinJMDC52Bbc_OFQLFAJuoC-DC5kdawkRo1J75Q5v3XOpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zVx9SXO4ZxQrKP+AIEHW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-04-05 at 03:36 -0700, Michael Chan wrote:
> On Tue, Apr 5, 2016 at 3:07 AM, Ben Hutchings <ben@decadent.org.uk> wrote=
:
[...]
> > > +static int bnxt_get_eee(struct net_device *dev, struct ethtool_eee *=
edata)
> > > +{
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct bnxt *bp =3D netdev_priv(dev);
> > > +
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!(bp->flags & BNXT_FLAG_EEE_CAP))
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0return -EOPNOTSUPP;
> > > +
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*edata =3D bp->eee;
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!bp->eee.eee_enabled) {
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0edata->advertised =3D 0;
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0edata->tx_lpi_enabled =3D 0;
> > What about tx_lpi_timer?
> We want to keep the tx_lpi_timer value so that it can be used again
> when it is turned on again.
>=20
> The user doesn't have to figure out what value to use if he just wants
> to use the default or the last value.

OK, that seems like a good reason.

> >=20
> >=20
> > And, wouldn't it make more sense to do these fixups to the internal
> > state in bnxt_set_eee()?
> I don't understand.=C2=A0=C2=A0If the user is enabling EEE, we take all t=
he
> parameters.=C2=A0=C2=A0If he is disabling, we don't take any of the param=
eters.

Right - it's just a bit weird that you keep the internal state in a
struct ethtool_eee but get_eee() returns a slightly different version
of the state.

Ben.

--=20
Ben Hutchings
No political challenge can be met by shopping. - George Monbiot
--=-zVx9SXO4ZxQrKP+AIEHW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXBCylAAoJEOe/yOyVhhEJhF8QAKXOnvI42HePJGOzdVLSe4pl
wGDvGW8FVPTP6Vlr/iNp5s1gFSRBPYIgZjaLcxqbRZ2C2AIum4qVk+TF/rXW5qH2
xoOGe9yPPUD5S1l1Q4K1qrjJ+5GagBHi7uWqSXGhkIJRiVr3xZYI6chKJgC0LoOp
MTtd+sjePa1N7faJXdvzBDJku8bnoQTJd+BuqxN+P9JElCd4XGfSm96CYLe1uw/m
R+YN1nvgEJhhn5Ax0xj30c+2OME6XQOffWKrvb7wEftAnr1PR74bjiI55pVhO4Yr
8+l8tyTRMh1vi+Hc0mrmVMo0NW9gHIcRZs1qmKdHsdTF52ktGqty8+OU6u1BefSC
dUlwiVd6PaZKRjEfTA0yzDT+VNLGFbito2nzrxE1rEtofiJY2y24vwNhZ62vPL9o
vyFJZzgy990Sk06kAXXPu4BRaAX9iFm3CVXxlpxwbLeTaujq9gTwiyV2kYLbMW/1
kAN1qULXcvwvjHxcODNMTiu7PZGcyAC34leyIflD+nP+IXZNjGYUrktGfJFRCUCU
TYCPrR1o0vnK4Uk62rCjBOs0PyXKduun+7CFxeZqm1C28PdSbLyk85BqqOuWksmZ
/pf+fPzKOu1iFjzoykAu1oG1GknR03NM75U0y5wNaBJ/AirpWGxJcOGk46LAcqOe
T4KN0F10gWXj+QT8XzZD
=2Y/u
-----END PGP SIGNATURE-----

--=-zVx9SXO4ZxQrKP+AIEHW--
