From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 5/7] can: clear ctrlmode when close candev
Date: Mon, 03 Nov 2014 21:47:22 +0100
Message-ID: <5457E9DA.6090702@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-5-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="hFohDBA3SqpKSSSSUw6muxnL7H5LtuXRb"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1414579527-31100-5-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hFohDBA3SqpKSSSSUw6muxnL7H5LtuXRb
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> Currently priv->ctrlmode is not cleared when close_candev, so next time=

> the driver will still use this value to set controller even user
> does not set any ctrl mode.
> e.g.
> Step 1. ip link set can0 up type can0 bitrate 1000000 loopback on
> Controller will be in loopback mode
> Step 2. ip link set can0 down
> Step 3. ip link set can0 up type can0 bitrate 1000000
> Controller will still be set to loopback mode in driver due to saved
> priv->ctrlmode.
>=20
> This patch clears priv->ctrlmode when the CAN interface is closed,
> and set it to correct mode according to next user setting.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

NACK, as discussed with Oliver.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--hFohDBA3SqpKSSSSUw6muxnL7H5LtuXRb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV+naAAoJECte4hHFiupUew8P/Asf0rKCMRQwo4r/2sSiQ3sw
T3nMo6UaHOXhEULE0IWYcvWr1i+qimPgwqPgORyls2DkAXN+hyNQMjMbkoQQz53T
THIZanssnNAAjTk/yipLA4EuibMoJ95pdHuIxq9J+Ld5pkNwLO++HxKqqI3f7HuU
YbZ9M/5SvAPsiIfPss4IxBNzaTHOn2Fa1C84w65QbbzUwHAPpvYRFGU66mca11iH
uSAMnR4Yb3yg+Crq4tTqqs04ZNp988XBia5jNq7/Xx4nPkrPeSSNRti2G+lJ1bsV
8wuW3Ct1s/QCsWVll+8BTE8YwS5WaSchCTwPxJ2X1Tet12b9TWsb3iTr6PNbj9qq
qeSG/VNebva6anlaKfebyYGZQ2iygmNklXGCEwhIerWb3rBDP1f3qjg7ppkePsVO
ryQSguyVIHhy7CEqh5Ld/WbtTBcLVaz3fEXZYJEJTlMxgTbeiqZ+Ls/f8tu6mcf6
o5N92y4pDLDZxGJs21lcyg7MPvH+d6/FeCycPPANYOQ5hylnvF80EZ3wjkOSA54f
46Zc+3cPzV0/q9t1NsKBzSbCoLC51m8VRmBjsMYqK/UaWgoJ/NW9opXJT/l6rLUD
0BjAJ6JzhKc3Mj3vk6BlLv/E67kjDntfg8dVE34tJnLBHDxZZpwdFW2xD0EeaclM
6PaqGNQ7p9u0ZdslnyiM
=dcS2
-----END PGP SIGNATURE-----

--hFohDBA3SqpKSSSSUw6muxnL7H5LtuXRb--
