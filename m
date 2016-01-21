From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: c_can: add xceiver enable/disable support
Date: Thu, 21 Jan 2016 12:32:54 +0100
Message-ID: <56A0C1E6.20107@pengutronix.de>
References: <1453375491-21140-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="eGvBNwsfUOw7IT4FI5PaHtekJ9xKah0eP"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>, wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57978 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965242AbcAULdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 06:33:04 -0500
In-Reply-To: <1453375491-21140-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eGvBNwsfUOw7IT4FI5PaHtekJ9xKah0eP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/21/2016 12:24 PM, Michael Grzeschik wrote:
> This patch adds support to enable and disable the xceiver
> in case it's switchable by the regulator framework.
>=20
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> ---
> v1 -> v2:
>  - always returning PTR_ERR in case devm_regulator_get fails
>  - removed inline wrapper functions with checks for xceiver =3D=3D NULL=

> v2 -> v3:
>  - adding documentation for the devicetree binding (already generic)

Please move the device tree binding into a separate patch and add the
device tree ML on Cc.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--eGvBNwsfUOw7IT4FI5PaHtekJ9xKah0eP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWoMHmAAoJEP5prqPJtc/HeFEH/0H+xMaYVxBJKy94J501TCXJ
iiHnzL8pnYrOvW+9ABu966hQ2mKnqtWbU8bc1kESfIAZB8v7UxMEnZcEHxGT8X7h
7a5/BnwrD2b6G50bKDuo15OZiVhbgKq/kwkCKG3jconvqtImtztthl+gmtTE+VaF
eLxpIe39Nj/9CIzkr2JmAwC4LkT/7YD25GiZuWFxIon56eVvUc864Fr5KWMI+Egc
GhZVzanaLT1VlRTCn4mds5hgh13kt58B3zhjR0gadtyUZdILVUAvMOpfmopljCVz
5R1+mZ0Il+c1Od2Rpm7vR7PCB4Q92YHgVDU/+6EiO635ut0pkcZPg36Q2SQ9CMo=
=Q6FT
-----END PGP SIGNATURE-----

--eGvBNwsfUOw7IT4FI5PaHtekJ9xKah0eP--
