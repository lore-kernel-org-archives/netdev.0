From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 0/3] net driver dependency cleanup
Date: Tue, 18 Jun 2013 03:21:47 +0100
Message-ID: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FJcAIbH3OItXSbGCeN96"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51457 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752595Ab3FRCV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 22:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FJcAIbH3OItXSbGCeN96
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Some Kconfig cleanup triggered by review of alx.

Ben.

Ben Hutchings (3):
  net: Move MII out from under NET_CORE and hide it
  at91_ether: Do not select NET_CORE
  net: Add missing dependencies on NETDEVICES

 arch/cris/arch-v10/drivers/Kconfig             |    4 +---
 arch/cris/arch-v32/drivers/Kconfig             |    4 +---
 drivers/net/Kconfig                            |   10 +++-------
 drivers/net/ethernet/3com/Kconfig              |    1 -
 drivers/net/ethernet/Kconfig                   |    4 ----
 drivers/net/ethernet/adaptec/Kconfig           |    1 -
 drivers/net/ethernet/adi/Kconfig               |    1 -
 drivers/net/ethernet/allwinner/Kconfig         |    1 -
 drivers/net/ethernet/amd/Kconfig               |    2 --
 drivers/net/ethernet/atheros/Kconfig           |    4 ----
 drivers/net/ethernet/broadcom/Kconfig          |    2 --
 drivers/net/ethernet/cadence/Kconfig           |    1 -
 drivers/net/ethernet/cirrus/Kconfig            |    1 -
 drivers/net/ethernet/davicom/Kconfig           |    1 -
 drivers/net/ethernet/dec/tulip/Kconfig         |    1 -
 drivers/net/ethernet/dlink/Kconfig             |    1 -
 drivers/net/ethernet/faraday/Kconfig           |    1 -
 drivers/net/ethernet/freescale/fs_enet/Kconfig |    1 -
 drivers/net/ethernet/icplus/Kconfig            |    1 -
 drivers/net/ethernet/intel/Kconfig             |    1 -
 drivers/net/ethernet/micrel/Kconfig            |    4 ----
 drivers/net/ethernet/nuvoton/Kconfig           |    1 -
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig  |    1 -
 drivers/net/ethernet/packetengines/Kconfig     |    1 -
 drivers/net/ethernet/rdc/Kconfig               |    1 -
 drivers/net/ethernet/realtek/Kconfig           |    3 ---
 drivers/net/ethernet/renesas/Kconfig           |    1 -
 drivers/net/ethernet/sgi/Kconfig               |    1 -
 drivers/net/ethernet/sis/Kconfig               |    2 --
 drivers/net/ethernet/smsc/Kconfig              |    5 -----
 drivers/net/ethernet/stmicro/stmmac/Kconfig    |    1 -
 drivers/net/ethernet/via/Kconfig               |    2 --
 drivers/net/usb/Kconfig                        |    4 ----
 drivers/staging/silicom/Kconfig                |    7 +++----
 34 files changed, 8 insertions(+), 69 deletions(-)



--=-FJcAIbH3OItXSbGCeN96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb/EO+e/yOyVhhEJAQqNLQ//YQYGvJACJssO61ZAE+NYspqMYphY3Ztn
OGb9eGX+vPPsL4Ok4KFZxfOvFTBArIcdVgJSb+HAgqp8oFNmD+PFOufj9ZaMvaxG
sW5dpMmSHvA15VLDbGRYuMd0JZrC7Ug3BbUmSys+7cmb70uXTMCEdFKa0+YOsS52
gm/QmDXeiiUIXsIPhX5cUHEGXBrFcoj/7v0BwbKvqxrAYiRdbPRwjR3PnDekROOq
6NeC1incY/WhifjdWGKFh14yHuUDfUwgk0OgELvLL8iTajla38C77Gtt/A/VdizY
LTbktUCb4SvUIsPwscPEWaaZ7QefowVa44qAFOi5A/koPO6dxaoODFoPsM2Gl4Ob
KarMPbUTAX/cTZcM9OpW4YpdSmFmvz/hGm7kY/LEP+zuyWLTfB5Aqe+kQr7Y+1YH
zqreg1ZTko2XLpRAx9c/Tg+hVeP6/aPSPmZQrtVPJ2D2c+6pYz63+OhX8z7KB/e9
MBmA5TGB91wKWpgz4Mz7sh6refXUsnG0HU67mBibYefBVoWfPFqalbW/uoNGMz1P
+7jJXE1IGZ+/kdJOoiV2UoUUj0D+dbqfpTj6DqExz1/x6c35hfIdtCiHve9IAaKb
ipdFEBQkpUH7WpKNmumBzPA8TZTbZ77CYN7RZ96THnnA4+oVVt26DuKXcf2M26VJ
JdY4lS2nK2A=
=j+15
-----END PGP SIGNATURE-----

--=-FJcAIbH3OItXSbGCeN96--
