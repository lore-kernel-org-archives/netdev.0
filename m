From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: mcp251x: Replace create_freezable_workqueue with
 alloc_workqueue
Date: Mon, 11 Apr 2016 10:35:39 +0200
Message-ID: <570B61DB.9070909@pengutronix.de>
References: <20160408153210.GA15068@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TOhk9DpAvsb1W32dF343tIhEb1tpffRfC"
Cc: tj@kernel.org
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160408153210.GA15068@amitoj-Inspiron-3542>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TOhk9DpAvsb1W32dF343tIhEb1tpffRfC
Content-Type: multipart/mixed; boundary="sQrJ3C3pfEgiGmfwRoPSRAiXxADgGwVB6"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>, wg@grandegger.com,
 linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: tj@kernel.org
Message-ID: <570B61DB.9070909@pengutronix.de>
Subject: Re: [PATCH] can: mcp251x: Replace create_freezable_workqueue with
 alloc_workqueue
References: <20160408153210.GA15068@amitoj-Inspiron-3542>
In-Reply-To: <20160408153210.GA15068@amitoj-Inspiron-3542>

--sQrJ3C3pfEgiGmfwRoPSRAiXxADgGwVB6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/08/2016 05:32 PM, Amitoj Kaur Chawla wrote:
> Replace scheduled to be removed create_freezable_workqueue with
> alloc_workqueue.
>=20
> priv->wq should be explicitly set as freezable to ensure it is frozen
> in the suspend sequence and work items are drained so that no new work
> item starts execution until thawed. Thus, use of WQ_FREEZABLE flag
> here is required.
>=20
> WQ_MEM_RECLAIM flag has been set here to ensure forward progress
> regardless of memory pressure.
>=20
> The order of execution is not important so set @max_active as 0.
>=20
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Acked-by: Tejun Heo <tj@kernel.org>

Applied to can-next/master.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--sQrJ3C3pfEgiGmfwRoPSRAiXxADgGwVB6--

--TOhk9DpAvsb1W32dF343tIhEb1tpffRfC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXC2HbAAoJED07qiWsqSVqTx4H/RZu1D52slftsplnUe+1SaNU
Xwp1tHXszSt5MZy2x8ss1hPBUnHkbAKQUqLm/jLx9ZEqHl8BmLkRVvH2LDd0/Ysv
+R1GSyKecHdd8dk4VpOoxZB7bhKz6y54HPzLyaEPzRXGjwawoqg+3XiY/lC5lIJ5
BsPhaoYZPAijdxXXVJ3+doniroVwe0EnrDJ/UzvQG3af2ZdUN71aq0IfW2QR8yn0
rbLsj0YwcG+kU6U+wnRR4jF8Zk84cs1UYh8mT4WKXNm3WHLPdgGbrSZPVhj2Z44k
GLGekznYbp8focxG1CoP3CWzWZIMH2ESTBskR6k2jI+kgZzbwFqwEvOI/lNoprQ=
=Wc+h
-----END PGP SIGNATURE-----

--TOhk9DpAvsb1W32dF343tIhEb1tpffRfC--
