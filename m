From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 2/7] net: powerpc: remove the legacy iSeries ethernet driver
Date: Thu, 8 Mar 2012 15:33:53 +1100
Message-ID: <20120308153353.ee2ff35c8ebe7ee66fa374e9@canb.auug.org.au>
References: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__8_Mar_2012_15_33_53_+1100_JvuX4KH4Te95FULA"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:33907 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab2CHEnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 23:43:40 -0500
In-Reply-To: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__8_Mar_2012_15_33_53_+1100_JvuX4KH4Te95FULA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

This driver is specific to the PowerPC legcay iSeries platform which is
being removed.

Cc: David Miller <davem@davemloft.net>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/ibm/Kconfig        |    4 -
 drivers/net/ethernet/ibm/Makefile       |    1 -
 drivers/net/ethernet/ibm/iseries_veth.c | 1710 ---------------------------=
----
 3 files changed, 0 insertions(+), 1715 deletions(-)
 delete mode 100644 drivers/net/ethernet/ibm/iseries_veth.c

diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kc=
onfig
index 9e16f3f..b9773d2 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -29,10 +29,6 @@ config IBMVETH
 	  To compile this driver as a module, choose M here. The module will
 	  be called ibmveth.
=20
-config ISERIES_VETH
-	tristate "iSeries Virtual Ethernet driver support"
-	depends on PPC_ISERIES
-
 source "drivers/net/ethernet/ibm/emac/Kconfig"
=20
 config EHEA
diff --git a/drivers/net/ethernet/ibm/Makefile b/drivers/net/ethernet/ibm/M=
akefile
index 5a7d4e9..2f04e71 100644
--- a/drivers/net/ethernet/ibm/Makefile
+++ b/drivers/net/ethernet/ibm/Makefile
@@ -3,6 +3,5 @@
 #
=20
 obj-$(CONFIG_IBMVETH) +=3D ibmveth.o
-obj-$(CONFIG_ISERIES_VETH) +=3D iseries_veth.o
 obj-$(CONFIG_IBM_EMAC) +=3D emac/
 obj-$(CONFIG_EHEA) +=3D ehea/
diff --git a/drivers/net/ethernet/ibm/iseries_veth.c b/drivers/net/ethernet=
/ibm/iseries_veth.c
deleted file mode 100644
index acc31af..0000000
--=20
1.7.9.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__8_Mar_2012_15_33_53_+1100_JvuX4KH4Te95FULA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPWDaxAAoJEECxmPOUX5FE8kEP/2C/1rHfDaMozoO0muU6cfB8
p5TczBBKC4gBWc2YdqJkRwSPVpFA7x4ZRJHligVqPzmmsKYSwWXVKJCfbJi5nWMb
mpGAw+8LEu5Xyr86J8Pbm9Rc8lGDjFlReK5DxBLc5tZirLHZrHpI3uCdamUzBaPC
3xr+xeaLEoX7qlgaTXGrTywDeCDgFxRVf9hooOs8bBpZczF/HhdtZAHF/0IFl4+k
GlJf8muG7VyD6jcRWAj7hMRArx3DA1+AZDhkB/UVnrAAf24GigtXzc3r3DpkUbfA
B9Xk5JLAzW3SpuQ4o96DYyznP1OSv9BcbGGq4C4wSCVHR36lYSe57zmY0cbOP0Lj
Paq81zIaJzX5cb74v8MVxmbqi6jGrGeQqdLb9owPS9+APeBYmQWhID3nGxt/n9Hq
c48zQodfEw/TAFcwfn40vt61A2kUUouCDvIPkA9+JqUXT3rHFmx6Yr+xjX1kACPw
//qibx2zCYG+8U9ACSx6MPuVKtU1e7gFop+qyJLhg3AFeUh2VxckLtGxDAFEEupP
Y2ZtnGnbmYez3Kk3uVNIPT7ISbPJmJnCIUes75+3mB5Sv8lBn6R9ZTBN5b5LuL1W
Q1Ki6kgvPki7USUimVuW3u/caiKB+s7kv0qBWUn7Dru5Yf49QBmLH4BaAVwjc7XP
mARgdzii4nhkPp5/GLbF
=TPGz
-----END PGP SIGNATURE-----

--Signature=_Thu__8_Mar_2012_15_33_53_+1100_JvuX4KH4Te95FULA--
