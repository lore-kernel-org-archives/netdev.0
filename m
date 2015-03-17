From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: gs_usb: check for kzalloc allocation failure
Date: Tue, 17 Mar 2015 09:04:52 +0100
Message-ID: <5507E024.9090801@pengutronix.de>
References: <1426545744-3317-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="s3MnaLfVwgssoBh5Uf46kMQWD1mtOAXBx"
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1426545744-3317-1-git-send-email-colin.king@canonical.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--s3MnaLfVwgssoBh5Uf46kMQWD1mtOAXBx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/16/2015 11:42 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>=20
> smatch detected the following issue:
> drivers/net/can/usb/gs_usb.c:904 gs_usb_probe() error:
>    potential null dereference 'dev'.  (kzalloc returns null)
>=20
> Add a check for null return from kzalloc and return -ENOMEM
>=20
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks, applied to can.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--s3MnaLfVwgssoBh5Uf46kMQWD1mtOAXBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVB+AnAAoJECte4hHFiupUzeQP/RVvTe265T4pUOQBTlO1zPFA
p4rm1kG8dMl77A2LGNb5gCz6f6XtPiQNNqs/0aEpz0zpVEPby/KA+WdwrUmUllKM
BYpu6SQeCRg6y8w3Y+zZEMz5KJti9re3+8RRKQudcrBisNdMOTiFZ/+O0AKZBAiS
tcH8/GNCL93y1BgMA84oNmaUi3tdUiRutsEskeuHdgSA7Sk0RxcscBaI24doajTu
CsfwMogEc76G3/wIddSv8tRr46gBmi1tafG7t/xgvezbQukX+4FpdhbIKgLVtawv
EkyNm4KdXqEN2ec6OhCFKtag8ldbechtB5wHK9FBZI96paIfur72ZoxqBDcw0vQp
XGw4n0/8UsuDH+5tjmkEgRuo9FScW5mDaNgBrZkP6LJIJ5H6esIWFZVe4nKukH2o
Xfn4FVSYPctF1O3fXUeDJKv4EcPdg1zNAvG5X+my0NbtQ/EiNSwI+4cE/F1k7YbN
io/51uTbTX3T7GUm1U1SJgzfQTLPBDm9rCXxF3YX2CbKnoYhoiPwpoZjrXWOEdeJ
cnRtmLSvBl8hbybkYvMcf8C+RWJI7N5ldJe/IaAl0Rb74e2p/WS38yWhsNBdLT0E
PMVsUEcQqiRHDhnYRf/izk7tnW+t6ZbJ7Nt5Q64oSugxQ7XVYPeNPFwufW263wbd
7YgxIKktXJ1/ebzYBtfN
=G0L8
-----END PGP SIGNATURE-----

--s3MnaLfVwgssoBh5Uf46kMQWD1mtOAXBx--
