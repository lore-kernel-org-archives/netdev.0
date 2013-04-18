From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Thu, 18 Apr 2013 13:18:43 +1000
Message-ID: <20130418131843.bfeb6b1ad5fba1b0f706076e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__18_Apr_2013_13_18_43_+1000_KNU/WCBiq_VN2ZdP"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org,
	Vipul Pandya <vipul@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__18_Apr_2013_13_18_43_+1000_KNU/WCBiq_VN2ZdP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/infiniband/hw/cxgb4/qp.c between commit 5b0c275926b8
("RDMA/cxgb4: Fix SQ allocation when on-chip SQ is disabled") from the
infiniband tree and commit 9919d5bd01b9 ("RDMA/cxgb4: Fix onchip queue
support for T5") from the net-next tree.

I think that they are 2 different fixes for the same problem, so I just
used the net-next version and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__18_Apr_2013_13_18_43_+1000_KNU/WCBiq_VN2ZdP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRb2YTAAoJEECxmPOUX5FEFpcP/jxk88uFsqeNw4wl1AXsa0ql
B/bW1x/ehp6kumkS1/1YYl8SoACtTr8FnBKJVv3hWKGQ7ZD8iQzqV1kcTnw32M5y
7gfgalnf+P3Pj156sI9onURhUUglq0u8+aN6skysnB9W4ucvCFq32bpYGn2jA89w
tVSZZTJS9O7XAMBuKpizEar+nk+gA++T3FKpynFoaZeizyoT6YKaMAuiXxMoGP3O
0odvLdUFmIalkcn15wkIIinrtgK0nkXy1QBeipxVtBusuuJhxp9fiI+cuXw6whCm
VWyfN72bh8PT2nri+xjNJI4TO+K4OZKjDN2MVXsRwVApNz/j0ML6TOSTWWemLscR
mBh2i4XXkhgY2PKHYioeubuCGbI6MAFXky9QQulOIV4GdZqeK16FwxOBYJsxxqc5
8+23I0V2OHloFe1ss3+gkBz1Niyb83EDRk1+wLGyydvotwpMj0s6P91rfKXO5s8p
q9AJM7XuNWn8SCsBjr280yfQeyoKoGsG9Be6y6grEZraasBCrVi4tqoKdi/U6SCM
Rxg5y1sKI2RgIpXlHNKsGzmXpA+tyte0HotPnVMvK/j54PXT7cRpTAo9Xy1o5X8r
GVMBSq9aw3Mgb0oBDoPufLPwsOmb8dwa2qpGgjpDpYoEx/OWRfZkcQX0ykwt+Ta3
fgO9YHHVfE9V8LwZP/IN
=qH0d
-----END PGP SIGNATURE-----

--Signature=_Thu__18_Apr_2013_13_18_43_+1000_KNU/WCBiq_VN2ZdP--
