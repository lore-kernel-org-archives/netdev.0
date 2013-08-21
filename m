From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] net: can: at91_can: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 12:16:39 +0200
Message-ID: <52149387.4060007@pengutronix.de>
References: <1377080103-33872-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="MmrCVucN58Sg5sl5tHS3ufIQgJPw84An7"
Cc: wg@grandegger.com, davem@davemloft.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com
To: Libo Chen <libo.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36805 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485Ab3HUKRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:17:22 -0400
In-Reply-To: <1377080103-33872-1-git-send-email-libo.chen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MmrCVucN58Sg5sl5tHS3ufIQgJPw84An7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/21/2013 12:15 PM, Libo Chen wrote:
> Use the wrapper functions for getting and setting the driver data using=

> platform_device instead of using dev_set_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
>=20
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

tnx, applied.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--MmrCVucN58Sg5sl5tHS3ufIQgJPw84An7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIUk4cACgkQjTAFq1RaXHOa2gCcDah9fhIKLkT2x09Z3UvnnzlQ
A48An1o+9xjAdA/sp+RZffnzuruNLuP1
=HP9z
-----END PGP SIGNATURE-----

--MmrCVucN58Sg5sl5tHS3ufIQgJPw84An7--
