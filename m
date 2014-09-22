From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 22 Sep 2014 11:52:40 +1000
Message-ID: <20140922115240.51c9a6fd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Jk5dDN7Z2zuV9vOMi2iwbmw"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Jander <david@protonic.nl>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Jk5dDN7Z2zuV9vOMi2iwbmw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/can/flexcan.c between commit fc05b884a31d ("can: flexcan:
correctly initialize mailboxes") from the net tree and commit
cdce844865be ("can: flexcan: add vf610 support for FlexCAN") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/can/flexcan.c
index 6586309329e6,2700865efcad..000000000000
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@@ -824,8 -859,7 +883,8 @@@ static int flexcan_chip_start(struct ne
  	struct flexcan_priv *priv =3D netdev_priv(dev);
  	struct flexcan_regs __iomem *regs =3D priv->base;
  	int err;
- 	u32 reg_mcr, reg_ctrl;
+ 	u32 reg_mcr, reg_ctrl, reg_crl2, reg_mecr;
 +	int i;
 =20
  	/* enable module */
  	err =3D flexcan_chip_enable(priv);

--Sig_/Jk5dDN7Z2zuV9vOMi2iwbmw
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUH4DvAAoJEMDTa8Ir7ZwV1YsP/jFx2tjNgR/WURmwaW2Lpiss
p9Cw8vJckzLu80lgcYZmXhp8+ROv2Qe6GFUkU3pHsNBM1YOqM6gYsL+ib71OIdcg
b07EWyRuJ8RROtSUvE3iiRxEJCJQ1Gl6XjIzndKJL69z0v6zeYtZ75ORuHgzwlo1
LhIPkmBx8/YG2rBLmN+PXFSvypYooa4Ze0DmpGezMTxoG+Y+YIjdQ2Bh6GOX8FVv
4efComZTz2kssa1rKEy1PZ/G9Cce/PWfsu8pRmeyQmr1m9OflvCvg6Pc/63ys3FQ
7ULqFKd5XlzQSFm1R2n+RqGnFko712gqJVMxqr35K0l7+iJ2lsTpFYt5tJtl69El
XWxbeoM3Q6q0pO/13c6cWfMziqEkabTeEBgBzt+UHyDxXqXEOjnDJdRe1p8e8gqf
n5RJZYiQIuBU7+gE1yC+8qcno6ZARzqHI9h4T0KcysYN6JfCyEiFxZwc9zm1/OpV
y+MyVrzWJP8WwxiPUwu3EpsODSO6A81Y1WaphUiIYkxYLJxLbcR/pybkrZ8cs6vc
V6707yqgZyI4gM8HwNfXUaw7beDDBp8WYlkMSJdEPePE3GpoecuajCh4rDWMiVK8
AjUQP9Csv1x7XLwE8rlaCYkjpjUTN8f6KjN5Jh86Odzn2PR3rVBRfFVZOp+1BO0M
wkDIEkosNOTC1qWL6s6O
=xjoc
-----END PGP SIGNATURE-----

--Sig_/Jk5dDN7Z2zuV9vOMi2iwbmw--
