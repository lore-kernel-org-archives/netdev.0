From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net tree
Date: Tue, 31 Aug 2010 11:55:08 +1000
Message-ID: <20100831115508.078eb2fa.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__31_Aug_2010_11_55_08_+1000_a2BO.BmthvtArIjo"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__31_Aug_2010_11_55_08_+1000_a2BO.BmthvtArIjo
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64
allmodconfig) produced these warnings:

In file included from drivers/net/stmmac/stmmac_ethtool.c:30:
drivers/net/stmmac/stmmac.h:111: warning: 'struct platform_device' declared=
 inside parameter list
drivers/net/stmmac/stmmac.h:111: warning: its scope is only this definition=
 or declaration, which is probably not what you want
drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
drivers/net/stmmac/stmmac_main.c:1744: warning: cast from pointer to intege=
r of different size
In file included from drivers/net/stmmac/stmmac_mdio.c:31:
drivers/net/stmmac/stmmac.h:111: warning: 'struct platform_device' declared=
 inside parameter list
drivers/net/stmmac/stmmac.h:111: warning: its scope is only this definition=
 or declaration, which is probably not what you want
drivers/net/stmmac/dwmac1000_core.c: In function 'dwmac1000_dump_regs':
drivers/net/stmmac/dwmac1000_core.c:56: warning: cast from pointer to integ=
er of different size

Probably all revealed by commit ac75791aa943c7953521cb4fa7728bf51f9abd2d
("stmmac: remove dead option in the driver's Kconfig") which allowed this
driver to be built on most platforms.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__31_Aug_2010_11_55_08_+1000_a2BO.BmthvtArIjo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMfGD8AAoJEDMEi1NhKgbsOpUIAJNj39RLYV2OWawNup622XVs
BfG760DbZtMcWQv8f75GbOJEumVAcvqv9UA0DJLA19QaYdfsRbSF2d7c/hfdAmSo
u9rakcTMtxRfeLqGeSLr1uz4ClSNbf01M0q5n2OYn3+C4Hq+aRGcrfrnJy5dZoDE
qvWG/1WiMQ96DB2yrXpSlWhGYZxaEuHicbgk0lUvOdqLkoiqYJKBMlY7KzKM/k85
LKKjTZxtRjq6OxWs993JVmqdwTMwRJr8DFcJmq42rDpAMvDtlka2g1EHb0NRFfQJ
Bxswp+h+JBn2sq69j/5mWrrJKF0sXhvOf5XZtRY8TKdX6Tvy1FlR4L39lIUIBsQ=
=O0NB
-----END PGP SIGNATURE-----

--Signature=_Tue__31_Aug_2010_11_55_08_+1000_a2BO.BmthvtArIjo--
