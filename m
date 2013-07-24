From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] bgmac: make bgmac depend on bcm47xx
Date: Wed, 24 Jul 2013 13:26:01 +1000
Message-ID: <20130724132601.94633488e3cb8a3b84267247@canb.auug.org.au>
References: <1374614929-7528-1-git-send-email-hauke@hauke-m.de>
	<20130724110858.01e033323d739cf6b998e2ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__24_Jul_2013_13_26_01_+1000_qVw9_DmidIX24k5b"
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-next@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130724110858.01e033323d739cf6b998e2ea@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__24_Jul_2013_13_26_01_+1000_qVw9_DmidIX24k5b
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, 24 Jul 2013 11:08:58 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Tue, 23 Jul 2013 23:28:49 +0200 Hauke Mehrtens <hauke@hauke-m.de> wrot=
e:
> >
> > bgmac uses bcm47xx_nvram.h which is only available when BCM47XX was
> > selected. Earlier BCMA_HOST_SOC depended on BCM47XX so this was not
> > build on any other archs, but that changed. We should modify this
> > driver to get access to the nvram or the variables through platform
> > data.
> >=20
> > This fixes a build problem in linux-next reported by Stephen Rothwell:
> >=20
> > drivers/net/ethernet/broadcom/bgmac.c:19:27: fatal error: bcm47xx_nvram=
.h: No such file or directory
> >  #include <bcm47xx_nvram.h>
> >                            ^
> >=20
> > Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> This patch really needs to go to John as the patch that exposes the
> breakage is in his tree.

I applied this to the wireless-next tree merge today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__24_Jul_2013_13_26_01_+1000_qVw9_DmidIX24k5b
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR70lOAAoJEECxmPOUX5FEJxIP/A3pq/z/liEUwsmQk10V5ITr
Kx9HR/rRTthxqIr627xnhlD6lb/Ugm1Lk2/cE5Wjt7OutV9DB6W597PDeGqJVv8c
rkUnPjAb+qQaMrU11JsDxLic7pfEDPxFY3CyLDdsCq0QebLCH43rjXOmiEi7XC1j
2N56lEAsA5lHyhSgYMwffCvQBpOnJCV3ZZlJ/lp68tQcbddKjAkJQCvCZFLjyZMF
HQlvyh0b7Jx7g1rbe555vlZO/pID8hj0HcZeDPu0pdz5X6C4cSP5Ai2Lv1sXeXvg
nTsUAEme4tmu7uAxAPVnVC28GKhhynEE9D7kx9Jp/6UwvzZjgogAdoAYfdl3py97
6+H6fvadYHwJ0qHvoCbmHeuZuoyDoubBgGBMLQPtsAO+bUTnVOBZFQSwJVcf1/Z8
+ShnaNCM2G5xhQjMjxO8wFgDtgVp5DSMeXdkkAdplNdj7LoQdlmGhDefpKlCzLD7
zleTUKy3M57BAAr5XfDquRiSE4bfA06zhR+pO+nQCJtd/+0Nq4xGuM+wTq1/1zT2
y78VwEUJuBLiwJ7N354O80a2zvy4NPmiBlQS/l20Yraa8BfWY9ATT4koEpl9I5DW
+BxBqyRN1Id6/RaEgcpGoWuN5YiqIHNY1V6j/7MixNd5W7lEQhjIAlxHxoFqxyXQ
at+UwbNj6W8UFumCNnEE
=53oc
-----END PGP SIGNATURE-----

--Signature=_Wed__24_Jul_2013_13_26_01_+1000_qVw9_DmidIX24k5b--
