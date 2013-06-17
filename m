From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Mon, 17 Jun 2013 16:39:20 +1000
Message-ID: <20130617163920.04523ba6de50bcc81563f33e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Jun_2013_16_39_20_+1000_Tz4qhwu7n79U/gdQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Bastian Hecht <hechtb@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Jun_2013_16_39_20_+1000_Tz4qhwu7n79U/gdQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/mach-shmobile/clock-r8a7740.c between commit e5c9b4cd6651
("sh_eth: get R8A7740 support out of #ifdef") from the net-next tree and
commit 9e0b428f079d ("ARM: shmobile: r8a7740: Add interim sh-eth device
name to clocks list") from the arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/mach-shmobile/clock-r8a7740.c
index ae93f94,7fd32d6..0000000
--- a/arch/arm/mach-shmobile/clock-r8a7740.c
+++ b/arch/arm/mach-shmobile/clock-r8a7740.c
@@@ -591,7 -594,9 +594,9 @@@ static struct clk_lookup lookups[] =3D=20
  	CLKDEV_DEV_ID("e6860000.sdhi",          &mstp_clks[MSTP313]),
  	CLKDEV_DEV_ID("sh_mmcif",		&mstp_clks[MSTP312]),
  	CLKDEV_DEV_ID("e6bd0000.mmcif",         &mstp_clks[MSTP312]),
 -	CLKDEV_DEV_ID("sh-eth",			&mstp_clks[MSTP309]),
 +	CLKDEV_DEV_ID("r8a7740-gether",		&mstp_clks[MSTP309]),
+ 	CLKDEV_DEV_ID("e9a00000.sh-eth",	&mstp_clks[MSTP309]),
+ 	CLKDEV_DEV_ID("renesas_tpu_pwm",	&mstp_clks[MSTP304]),
 =20
  	CLKDEV_DEV_ID("sh_mobile_sdhi.2",	&mstp_clks[MSTP415]),
  	CLKDEV_DEV_ID("e6870000.sdhi",          &mstp_clks[MSTP415]),

--Signature=_Mon__17_Jun_2013_16_39_20_+1000_Tz4qhwu7n79U/gdQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRvq8cAAoJEECxmPOUX5FEnIAP/1hQ/DbdAWJVD45WG1LmSAVR
Fmcj++RJaXkfQjT1Lv8J71lMl3uz9axxA4gsTQWliO35fJUU2FFKY+2ihT29rWfC
VmvFUsVA23xy9GkDQk9+1W4+JCZ+UhEa/W7mW+eMlOhmcdWlsuFEEIJM3z3tTU9n
ePKKJMsi1z5OIK4PwbVl8cH+KQ6teetBB7JXd5pgEos4o48YRVArjUxHGjbiWguR
SJW+WLj17nLx/rY/5Kbazs93eBApQOL7Lyki4KmT3KzjxhBat0APl45QClTtqJh5
WfaaDzIa1qci14Afb2R4MkbycwVHbKCsaacBuNCib5U+QMpTobIe7abPr9LOJ6jh
vlIGxjim7AM5/hq1QLdIIobV7nCJ6bLITPr3U408OmOIS3oV18oGYbwcjyNsdFf3
PzKUkm/WRGX3Eru3Iv48nv+uI5gqx7kLQF7lxDtfj8J+yWKVMzJeQ6P+XvsuHZXw
2Z2nRtvEOXGN/TgVWfSRx3qAdYA47eS+NSFDVX8MA7xavrNCyTvYSiyU/78yo0km
Qt26SpROqOCfEpGUZrID0dMXA5D+DjWsTmODTNqV45bSZGpUlYXZLfLYlUJ3OEGZ
+HP6QccLfwTuVFtHb7WGAKMfhqxudXgDR9RtN9tTAzh2SSJeI9NbQRwHRa5Gx+ow
Ub6bsjIT7pcKYdKznYau
=KcJ6
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Jun_2013_16_39_20_+1000_Tz4qhwu7n79U/gdQ--
