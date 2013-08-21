From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH next] drivers: net: can: c_can: add type cast from 'unsigned
 int' to 'int'
Date: Wed, 21 Aug 2013 11:45:02 +0200
Message-ID: <52148C1E.3020709@pengutronix.de>
References: <521483CD.8050907@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="MCv54WLWxVEwgIQmRgLhl6DqLgoeFvKv3"
Cc: wg@grandegger.com, anilkumar@ti.com,
	Tony Lindgren <tony@atomide.com>, jg1.han@samsung.com,
	David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49749 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab3HUJpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 05:45:25 -0400
In-Reply-To: <521483CD.8050907@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MCv54WLWxVEwgIQmRgLhl6DqLgoeFvKv3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/21/2013 11:09 AM, Chen Gang wrote:
> 'priv->instance' may less than zero, so need a type cast, the related
> warnings (allmodconfig, "EXTRA_CFLAGS=3D-W"):
>=20
>   drivers/net/can/c_can/c_can_platform.c:198:3: warning: comparison of =
unsigned expression < 0 is always false [-Wtype-limits]

Tnx, I've tweaked the commit message a bit, will send a v2.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--MCv54WLWxVEwgIQmRgLhl6DqLgoeFvKv3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIUjB4ACgkQjTAFq1RaXHMYJgCfQAjIqxNerzOQC1llP4LG97ip
TKsAnRPAUsyfD5kNmQuMxFuWtFLh1mDQ
=pLp6
-----END PGP SIGNATURE-----

--MCv54WLWxVEwgIQmRgLhl6DqLgoeFvKv3--
