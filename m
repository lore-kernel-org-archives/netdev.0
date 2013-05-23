From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: use platform_{get,set}_drvdata()
Date: Thu, 23 May 2013 12:58:47 +0200
Message-ID: <519DF667.1050700@pengutronix.de>
References: <003901ce57a2$fd0f7450$f72e5cf0$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2XWCHWFMPNSVTRRBPAHLV"
Cc: "'David S. Miller'" <davem@davemloft.net>,
	'Wolfgang Grandegger' <wg@grandegger.com>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59362 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757910Ab3EWK7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 06:59:02 -0400
In-Reply-To: <003901ce57a2$fd0f7450$f72e5cf0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2XWCHWFMPNSVTRRBPAHLV
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/23/2013 12:47 PM, Jingoo Han wrote:
> Use the wrapper functions for getting and setting the driver data using=

> platform_device instead of using dev_{get,set}_drvdata() with &pdev->de=
v,
> so we can directly pass a struct platform_device.
>=20
> Also, unnecessary dev_set_drvdata() is removed, because the driver core=

> clears the driver data to NULL after device_release or on probe failure=
=2E
>=20
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied to linux-can-next.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2XWCHWFMPNSVTRRBPAHLV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGd9moACgkQjTAFq1RaXHM5HgCffK7WmJNdP7dS7AwOIcgrCB/3
tx4An2KHie/vFEJkoGu4hg8X65LTIwGX
=OLrN
-----END PGP SIGNATURE-----

------enig2XWCHWFMPNSVTRRBPAHLV--
