From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
Date: Wed, 3 May 2017 14:28:00 +0200
Message-ID: <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
 <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="LrSQr6VmWEBUrnFgse6LKBctcNelDvXTs"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, wg@grandegger.com,
        mario.huettel@gmx.net, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LrSQr6VmWEBUrnFgse6LKBctcNelDvXTs
Content-Type: multipart/mixed; boundary="ptpPMlRtoVucugJBNUEWL0e1aJQogc08V";
 protected-headers="v1"
From: Quentin Schulz <quentin.schulz@free-electrons.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>, wg@grandegger.com,
 mario.huettel@gmx.net, socketcan@hartkopp.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 thomas.petazzoni@free-electrons.com
Message-ID: <c45cc113-6072-a514-f956-1c2c61484a13@free-electrons.com>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
 <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
In-Reply-To: <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>

--ptpPMlRtoVucugJBNUEWL0e1aJQogc08V
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Marc,

On 03/05/2017 14:16, Marc Kleine-Budde wrote:
> On 05/03/2017 02:11 PM, Quentin Schulz wrote:
>> This adds Power Management deep Suspend/Resume support for Bosch M_CAN=

>> chip.
>>
>> When the chip resumes from deep sleep, the RAM needs to be initialized=

>> as it is done when the driver probes. The net interface also needs to =
be
>> closed and reopened to be fully functional.
>=20
> Are you sure it's the closing and opening of the net interface. Maybe
> it's the m_can_start() and/or the subsequent m_can_chip_config()?
>=20

You're right. The chip needs to be completely reinitialized (clocks,
chip itself) and it also closes and reopens the interface if I'm correct
with close_candev and open_candev.
I'm sending a v2 right away to fix the commit log.

Thanks,
Quentin
--=20
Quentin Schulz, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com


--ptpPMlRtoVucugJBNUEWL0e1aJQogc08V--

--LrSQr6VmWEBUrnFgse6LKBctcNelDvXTs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJZCczWAAoJEIS4mnU+4PGjFx4P/3k26G199FJSL/my8NyI+onN
w9LzqFNdi/gQ/eGuCpzIr4X4T3JDhaIIw44qk2Pc14T0KuVEcxxX8s7/lYcmYUiG
8o4u3+yLsjke+j5WiMT+TD17Q5/di/d383+Iu46yYyc2m8A74nU9gr2RIJhKe3Zm
2s4d7bUxXzSYsyBgSFZfZC3aj0SLzTo6uhsD/F/VgLa+BQQDAaD6rLel0mEhv2GE
jOPGYMG/btcNxLAx/xAorR4hwVBj0PmEkmiR/RIm/fKgUTugMiNOq819vvPyn+gT
Z6FnJYQaoDhvk5ZWXJS2TJmpLYG6zegpocTcWL0NqsTgAPGfCGCxydFNH/Hwb55I
eGHO3kWEeHf9tLkPmiWNuOUKn2jlC/otWhBZspe8bx8/E1aDlEHMy9s/ogSYBwby
MXxQsvbfRtrKDb0rt86QKu0UFIdlT/amFgV/uiHP8WMlWiAFVYDuVgEHeb8YGa+1
irSemarX9O+U8kuhw9e1ZM4kER2mhCNwFZAoKyAsBroRxqH8LV6ZDEnwNYaCQzJW
a3gzoQKRQKgRnv1lbd2LOjCpgN3QcwJwNFh+i9GD6b+gZbyMA+RysB1Gk9r7GbBJ
QfVpuv+Skkag2npypzrMWd4t+5civonuWqlMV8I8ZdeQ4vvb58G8qU7YUqLXwtYW
VLM0dLyoFi2l7Xym+1q5
=o62d
-----END PGP SIGNATURE-----

--LrSQr6VmWEBUrnFgse6LKBctcNelDvXTs--
