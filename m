From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next] can: ti_hecc: fix return value check in
 ti_hecc_probe()
Date: Tue, 25 Apr 2017 10:49:10 +0200
Message-ID: <a1ee93c5-7ca3-de28-d222-6a7583892eab@pengutronix.de>
References: <20170425064405.3964-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="3p0Vd2eoXRJThSdJ8NaQ0BmcMrPuiqUL9"
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Anton Glukhov <anton.a.glukhov@gmail.com>,
        Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45305 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1176909AbdDYItb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:49:31 -0400
In-Reply-To: <20170425064405.3964-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3p0Vd2eoXRJThSdJ8NaQ0BmcMrPuiqUL9
Content-Type: multipart/mixed; boundary="BOOUHqVOlhuCa5xHE1n9Ac4w0q1gIGNlI";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wei Yongjun <weiyj.lk@gmail.com>, Wolfgang Grandegger
 <wg@grandegger.com>, Anton Glukhov <anton.a.glukhov@gmail.com>,
 Yegor Yefremov <yegorslists@googlemail.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org
Message-ID: <a1ee93c5-7ca3-de28-d222-6a7583892eab@pengutronix.de>
Subject: Re: [PATCH net-next] can: ti_hecc: fix return value check in
 ti_hecc_probe()
References: <20170425064405.3964-1-weiyj.lk@gmail.com>
In-Reply-To: <20170425064405.3964-1-weiyj.lk@gmail.com>

--BOOUHqVOlhuCa5xHE1n9Ac4w0q1gIGNlI
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2017 08:44 AM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
>=20
> In case of error, the function devm_ioremap_resource() returns ERR_PTR(=
)
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
>=20
> Fixes: dabf54dd1c63 ("can: ti_hecc: Convert TI HECC driver to DT only d=
river")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Added to linux-can-next.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BOOUHqVOlhuCa5xHE1n9Ac4w0q1gIGNlI--

--3p0Vd2eoXRJThSdJ8NaQ0BmcMrPuiqUL9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj/DYYACgkQHv7KIOw4
HPa9EQf/WqeK3OXD7/8/xlm8C37DupQ8mrzB3aitn3UmM/RTqQ6We5FSxaaWtcNa
v5+0qf+Ob/4ptPdA6NiVxKh9SZ5xidjapoJkqj+sNNS5BBQTnNPbDbF+ZkR/exrf
9GVWNUGXVN8rZ6Ou6Bo6RwFdNwqw2CI104B8jZ5lmca5Zo7ycxYuDfUpWnGr32sp
BNsdGhaqwdk4pgZ5nNiwau+G4SYLRhVtX6JTR2lH5GXCoG9QS2QVPmrwwl+RTyGH
0vuuh5W5fxiG2u71otCTLxLCD6ivsewLc75emxDRoMxChSWKtXvZWc/eqB8ji8TT
6dAo8Yamrw46MY+BIskpFJnOGbv1Rw==
=ePey
-----END PGP SIGNATURE-----

--3p0Vd2eoXRJThSdJ8NaQ0BmcMrPuiqUL9--
