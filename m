From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] bgmac: make bgmac depend on bcm47xx
Date: Wed, 24 Jul 2013 11:08:58 +1000
Message-ID: <20130724110858.01e033323d739cf6b998e2ea@canb.auug.org.au>
References: <1374614929-7528-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__24_Jul_2013_11_08_58_+1000_ag9GYNau8qttZeTY"
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-next@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:56983 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab3GXBJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 21:09:09 -0400
In-Reply-To: <1374614929-7528-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__24_Jul_2013_11_08_58_+1000_ag9GYNau8qttZeTY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, 23 Jul 2013 23:28:49 +0200 Hauke Mehrtens <hauke@hauke-m.de> wrote:
>
> bgmac uses bcm47xx_nvram.h which is only available when BCM47XX was
> selected. Earlier BCMA_HOST_SOC depended on BCM47XX so this was not
> build on any other archs, but that changed. We should modify this
> driver to get access to the nvram or the variables through platform
> data.
>=20
> This fixes a build problem in linux-next reported by Stephen Rothwell:
>=20
> drivers/net/ethernet/broadcom/bgmac.c:19:27: fatal error: bcm47xx_nvram.h=
: No such file or directory
>  #include <bcm47xx_nvram.h>
>                            ^
>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>

This patch really needs to go to John as the patch that exposes the
breakage is in his tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__24_Jul_2013_11_08_58_+1000_ag9GYNau8qttZeTY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR7ykvAAoJEECxmPOUX5FEms8QAIKdECTaI148AlY1qD8REvJI
4eO67vVGlBJgBmfK8fLvuiesvBCoc71+sYbXvrgkWErQr9XJf7ms9WPK8LTHne6U
rda1vdQhIsJMOszOcsCQ7/YZI+f+fwX0LxHAQixNLE1y4Rh8PU6/tjo0qgSbPKml
5jz4uOx9I3qi0D78F7wlKoMFCTJ7ccNDSIhoNyUVn5AcN7n8XrPpO5YuEHqRXQYU
kAOHNVi+vcArJ3Ufn0HBiaRdRiRvbjum00tT6/7HHozOYxIO9hc/clbaFFOrocri
QuWlM3SGHf5yzVd1ykGRwVut245dEy7nRa5uRAuh8NstE8hmMt+1lNqilX6httxY
VxdYkLU1xYaBiGPAvqRByOBZBnaztxdV2xjVbUbm+3gm4N9SgY8Y/W1FkTEQVLCR
nhfcml/jpDfXzYqDnf3udF/PY0BpXowX2nb44Ru3C9jOc8OhrCFlQJOqgzfyJa7z
NS88BzFonFomSqzGCfQuTXKlTimem2pAMdXrKvBVRm0ftHBHg4FTUd0RxnZ+4cyO
FOqAkE8eq4FNjeWGeEgaZBItWXOmWbl77I0z9BWIVEWt0kysRNnH1iSrVM7ldFbw
Sgk9vndfAI4kgw23Teldaaxc5iyv1SSBThgeImqE88FUUSKiJ4q/AaGv9jqnuAog
sFbhqiYAUBR3egC5eMFD
=Fqq8
-----END PGP SIGNATURE-----

--Signature=_Wed__24_Jul_2013_11_08_58_+1000_ag9GYNau8qttZeTY--
