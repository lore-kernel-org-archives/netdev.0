From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
Date: Wed, 3 May 2017 14:44:32 +0200
Message-ID: <b340a104-9974-d575-670d-5b360dddb266@pengutronix.de>
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
 <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
 <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="A27OwiMNROUWvWwtvFEke1G0E2MqWb5KW"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--A27OwiMNROUWvWwtvFEke1G0E2MqWb5KW
Content-Type: multipart/mixed; boundary="nBonBgbvO3ghwGw7aEsftulsmdDmVxmgW";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Quentin Schulz <quentin.schulz@free-electrons.com>, wg@grandegger.com,
 mario.huettel@gmx.net, socketcan@hartkopp.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 thomas.petazzoni@free-electrons.com
Message-ID: <b340a104-9974-d575-670d-5b360dddb266@pengutronix.de>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
 <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
 <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>
In-Reply-To: <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>

--nBonBgbvO3ghwGw7aEsftulsmdDmVxmgW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/03/2017 02:28 PM, Quentin Schulz wrote:
> Hi Marc,
>=20
> On 03/05/2017 14:16, Marc Kleine-Budde wrote:
>> On 05/03/2017 02:11 PM, Quentin Schulz wrote:
>>> This adds Power Management deep Suspend/Resume support for Bosch M_CA=
N
>>> chip.
>>>
>>> When the chip resumes from deep sleep, the RAM needs to be initialize=
d
>>> as it is done when the driver probes. The net interface also needs to=
 be
>>> closed and reopened to be fully functional.
>>
>> Are you sure it's the closing and opening of the net interface. Maybe
>> it's the m_can_start() and/or the subsequent m_can_chip_config()?
>>
>=20
> You're right. The chip needs to be completely reinitialized (clocks,
> chip itself) and it also closes and reopens the interface if I'm correc=
t
> with close_candev and open_candev.
> I'm sending a v2 right away to fix the commit log.

:) I mean to fix the call to the proper function and _not_ calling
close() open().

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--nBonBgbvO3ghwGw7aEsftulsmdDmVxmgW--

--A27OwiMNROUWvWwtvFEke1G0E2MqWb5KW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkJ0LAACgkQHv7KIOw4
HPa5TggAvEpKjeJpjvUCrHDj5jc1ocnas+wQGkWhsa8XU+xJsbD/GzAUv6exiBDI
5q5/8UzEL5BJ54G45tl/Y5g9v3+63PkQj8zYzkrOW3p4tnA+MpLywquY8dbZo45o
G7BkxH0pGvY0p5uiu/J6TvJulEUbkmfL6Yzw8r9TTfn6I1N4eQ7f//avdbDR+3Zj
fjfcnyS4//i3l7bofwkScSkqLPK5s7Iik/wCDCosBsshNxVToT1FMKaQOfp5Pg4f
yh9/yhFqUnV3sgXdYGNDL9S0Lx/e1AQc1hkJS+yNy6/qrFX7aMr+Pzr9pBpbgAfi
gWXVQ8M13Vg77ZzGnmBVjaTNnsvgog==
=cxi4
-----END PGP SIGNATURE-----

--A27OwiMNROUWvWwtvFEke1G0E2MqWb5KW--
