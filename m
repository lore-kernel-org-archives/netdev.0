From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
Date: Wed, 3 May 2017 14:16:54 +0200
Message-ID: <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="iTPBP0wdBS41xrIln2nougfU52KFcm2dn"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170503121143.25090-2-quentin.schulz@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iTPBP0wdBS41xrIln2nougfU52KFcm2dn
Content-Type: multipart/mixed; boundary="VL5H8r0h1PqTWB3AjEaW1E5N3O63Xc6wD";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Quentin Schulz <quentin.schulz@free-electrons.com>, wg@grandegger.com,
 mario.huettel@gmx.net, socketcan@hartkopp.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 thomas.petazzoni@free-electrons.com
Message-ID: <39fcd931-eca6-2e89-ff8b-14a54e9342fc@pengutronix.de>
Subject: Re: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
 <20170503121143.25090-2-quentin.schulz@free-electrons.com>
In-Reply-To: <20170503121143.25090-2-quentin.schulz@free-electrons.com>

--VL5H8r0h1PqTWB3AjEaW1E5N3O63Xc6wD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/03/2017 02:11 PM, Quentin Schulz wrote:
> This adds Power Management deep Suspend/Resume support for Bosch M_CAN
> chip.
>=20
> When the chip resumes from deep sleep, the RAM needs to be initialized
> as it is done when the driver probes. The net interface also needs to b=
e
> closed and reopened to be fully functional.

Are you sure it's the closing and opening of the net interface. Maybe
it's the m_can_start() and/or the subsequent m_can_chip_config()?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VL5H8r0h1PqTWB3AjEaW1E5N3O63Xc6wD--

--iTPBP0wdBS41xrIln2nougfU52KFcm2dn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkJyjYACgkQHv7KIOw4
HPYBlQf/VyperIvkufXe4AE5diGFYYzPXEHqHgj6JONlsDNYG/2RutT02wXzUhM/
eagnRT9RUOlaQ2VcSsdO1h000ClKq4iZIe5yaOMgtSnXr9+kg5QpCbMTm+z1x22r
PTRdLOhLx5w+DRTQppvC7cZ/CAQTGN7//ozNQ+E99fvnoc8gWHHrhNgpD8zaFttZ
wUcpA5orwG2lpGjUMjV418L2UEya1RZUFz4dx6SLmvxKntYVk2mnhNYfU0mJziUO
RUIR4Of+feIpeNaa49s8otMntnPEO/lLo13yq5y2xBlCbrS/5w0HHF3hlAFeay1m
tlp1l6KKt+59SRLBxys+2nVY93V0Ow==
=sQK2
-----END PGP SIGNATURE-----

--iTPBP0wdBS41xrIln2nougfU52KFcm2dn--
