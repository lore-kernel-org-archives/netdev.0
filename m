From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V3 2/3] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 15:31:21 +0100
Message-ID: <545A34B9.2060001@pengutronix.de>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="n2uof6CVanXhGMk20TwpPqjLshS8AV6FT"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415193393-30023-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--n2uof6CVanXhGMk20TwpPqjLshS8AV6FT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 02:16 PM, Dong Aisheng wrote:
> Bosch M_CAN is CAN FD capable device. This patch implements the CAN
> FD features include up to 64 bytes payload and bitrate switch function.=

> 1) Change the Rx FIFO and Tx Buffer to 64 bytes for support CAN FD
>    up to 64 bytes payload. It's backward compatible with old 8 bytes
>    normal CAN frame.
> 2) Allocate can frame or canfd frame based on EDL bit
> 3) Bitrate Switch function is disabled by default and will be enabled
>    according to CANFD_BRS bit in cf->flags.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

I'm waiting on Oliver's Ack on this patch, then I'll apply 1+2.

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--n2uof6CVanXhGMk20TwpPqjLshS8AV6FT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWjS5AAoJECte4hHFiupUy8IP/3/GvGV9t5hZkXlvHEBHPvid
4W9AIJtEMKZacUogKRx94mmkuWKP2Qq2sIqbbhECjPzYOx7Fgmcw3R2am9IPLEV0
6Mv/Oqlgrb7baRGMdafTjonwNGiNCoaKEwUV7t6QPJNSixB8CPfuJwDYNp7yWgOg
mVrEI98JNtYMVCyY1gO2DK3qRzY4DBvJ8mjOVfvY3s+OcpMjhReSyB9MKEH534jM
DAtXRBpUTxE1LTjEdJ+HbywbYCWC9sTjP0BHPMtqV1e25cLszWL7oUxGl5rwFK8Z
jyHcXhItlcZJ2PAiPdZdcJYVr7ez2J5bPS7XOP5FoNP/7W9MLohjub6UWZcd77oY
UZud9t3dmSEam/Sgvmue9/SAZoJi4wPDni68nO2oYycAEz+bE8wwJ/eQkNe875J/
BANRXhVDsi0PB7bpGRSksK6EazZjbTY03YuDm3Krs/z4kHyQ9vkz7xu5MxJUnlYb
yLTkff6xAoFoERqInZfm1Pxb6uE59shEpwDPkJfwUDu/7yk6p3AjLQopaUbuZKjB
LU9/sq7atq/lvyAYtnoIYesFepQ7eoLtjWm3cjbyhaoLWzW+4at+dqio/nUvfU2Q
qZGgdj2y7r5LYnTDBmowq/xPGAHohzeZaEfo7wVaN5xodFoTYI/mJnMhYDcLYxH8
wExIlhEdg+RymLvtpQp9
=dKDD
-----END PGP SIGNATURE-----

--n2uof6CVanXhGMk20TwpPqjLshS8AV6FT--
