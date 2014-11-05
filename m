From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 2/4] can: m_can: workaround for transmit data less
 than 4 bytes
Date: Wed, 05 Nov 2014 12:32:21 +0100
Message-ID: <545A0AC5.80006@pengutronix.de>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <1415174326-6623-2-git-send-email-b29396@freescale.com> <5459F94C.1030506@pengutronix.de> <20141105103349.GA4007@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="8Gf3e99mLw798g5tF4DRRCJSJohkOM3kV"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141105103349.GA4007@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8Gf3e99mLw798g5tF4DRRCJSJohkOM3kV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 11:33 AM, Dong Aisheng wrote:
> On Wed, Nov 05, 2014 at 11:17:48AM +0100, Marc Kleine-Budde wrote:
>> On 11/05/2014 08:58 AM, Dong Aisheng wrote:
>>> At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
>>
>> Can you add the imx mask revision, too and the exact m_can version (is=

>> available).
>>
>=20
> What do you mean imx mask revision?

In my imx6sdl/imx6q data sheet it's called: Chip Silicon Version
(USB_ANALOG_DIGPROG), I expect that the imx6sx has a the same register.

> By reading the Core Release Register (CREL), it seems the exact m_can
> version is 3.0.1. (CREL =3D 30130506).
>=20
> So what about changing to as follows?
> "At least on the i.MX6SX with M_CAN IP version 3.0.1 (CREL =3D 30130506=
),
> an issue with"

Yes, please ass the imx silicon revision, too.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8Gf3e99mLw798g5tF4DRRCJSJohkOM3kV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWgrFAAoJECte4hHFiupUUPgP/i0M2rgcOQY/gskSAzkhFdtQ
gBp+4LEwCtTdCO0xJz1p6xh0HKuw3T9ccHPhVOnKhZ2UQ9NsBdADDrlSiDCR2N9a
Vwk1nje5sjqRldZVIxeUf1yQ/NAm/jj95I8LxrnHfx6S5aanVwVoxzn+BYvnqFYM
BE2m9p60P1gZQLtG8jiUcV1GmMtBe9I8gc72COY6MmhJMPRgq6rESFANNyczC2gd
BZxCXKh+zvl+Jq7XecU2493TarGb1aJS2W0znKGonRY5bzHUAqXeuzTkbUQ+W3fb
LJYJgtcBZx81MNYI2K6CHOCf0+ukHPdtF1fSWhU8LhkF8mbF/ZiKM79ZaH/3Mjfw
RaNBiljSIbajDl1IjfQbHNiEf8c3YM8ux0nx2AULpSpYv9ueEU0kVnHkU/4ocMie
9paS86i9KS2uPLPkdOpynCYaBf9NsAX7cb+tmqSy+zp1HT8szyBxHTkpY+1Sii3m
6q0jA5YVMizw/FWrFY7YEl5NnQtBt9RlXBYwhsmWIMjqd2zliUxAxqgynOM7UqpP
kXN/azbxD7MfYf13PskKuvwtSA4rLXZX74EGwGoWTBI79iDn3EoOReySULsWSdMr
s/EPOxpq6CR50w5z4owVcwSuY6Dbb5S0RUHFIvfRx7LmWWqQY6DKzkFdV4+4+cOA
FAeelDQtkrJobx62NnuZ
=X2Cg
-----END PGP SIGNATURE-----

--8Gf3e99mLw798g5tF4DRRCJSJohkOM3kV--
