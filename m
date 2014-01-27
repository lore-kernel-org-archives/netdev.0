From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] ethtool.8: Add missing 1G and 10G link modes, and full
 names for all modes
Date: Mon, 27 Jan 2014 01:22:15 +0000
Message-ID: <1390785735.2735.96.camel@deadeye.wl.decadent.org.uk>
References: <20131120022540.6464.98397.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-t54hC5KI/hEpYFP/NvQN"
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54208 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbaA0BWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 20:22:24 -0500
In-Reply-To: <20131120022540.6464.98397.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-t54hC5KI/hEpYFP/NvQN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The 1G and 10G backplane link modes were missing from the table for
the 'advertise' keyword.  Most link modes had only speed and duplex
listed; change them to be consistent with ethtool's own output.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I applied this on top of your patch.

Ben.

 ethtool.8.in | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index f320f7f..bb394cc 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -541,20 +541,23 @@ a hexadecimal value using one or a combination of the=
 following values:
 .TS
 nokeep;
 lB	l	lB.
-0x001	10 Half
-0x002	10 Full
-0x004	100 Half
-0x008	100 Full
-0x010	1000 Half	(not supported by IEEE standards)
-0x020	1000 Full
-0x8000	2500 Full	(not supported by IEEE standards)
-0x1000	10000 Full
-0x200000	20000MLD2 Full	(not supported by IEEE standards)
-0x400000	20000KR2 Full	(not supported by IEEE standards)
-0x800000	40000KR4 Full
-0x1000000	40000CR4 Full
-0x2000000	40000SR4 Full
-0x4000000	40000LR4 Full
+0x001	10baseT Half
+0x002	10baseT Full
+0x004	100baseT Half
+0x008	100baseT Full
+0x010	1000baseT Half	(not supported by IEEE standards)
+0x020	1000baseT Full
+0x20000	1000baseKX Full
+0x8000	2500baseX Full	(not supported by IEEE standards)
+0x1000	10000baseT Full
+0x40000	10000baseKX4 Full
+0x80000	10000baseKR Full
+0x200000	20000baseMLD2 Full	(not supported by IEEE standards)
+0x400000	20000baseKR2 Full	(not supported by IEEE standards)
+0x800000	40000baseKR4 Full
+0x1000000	40000baseCR4 Full
+0x2000000	40000baseSR4 Full
+0x4000000	40000baseLR4 Full
 .TE
 .TP
 .BI phyad \ N

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-t54hC5KI/hEpYFP/NvQN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuW0x+e/yOyVhhEJAQovdg/+PXMzkqM5xd+veNNy4LqcJVl2BZd3k/kC
nwYIEMQT3Xomd1gAdMthB0c7Eu0gSEsXW5E+q2G6giPA+uEMZyuxJ4M6u1gNB0VY
oCkKvzRXFEcFDsE06noebP4S+9caBXDXj1bRKWIHzuN/9QhTbvuzD1m5LvxBNlYu
XwtSJo9lSRUuqy6m9okax6m42se/96IdT1JZWKXbI02+gXB9j19eMmCtMR0Cp/Un
Uhq20p02oNdKe86xDNosnkLktFEdcG0AvkpNwtDiD1JQmLKDzRiYpnneamdns1vA
D+IWIrIZf+Ti1Nrf4iimKVgcISUFz6fZmGPLsGnihK8BbndKeoNz9dVo/wB8VY44
l85OJLZ/XTUmaf23jaCF7TsEi1OF0UAp9MUIzaTlKrgV9yl4HmXjYdAlxkEE6r6e
R7bQ4C5gbkx9oOM7qM9yxnPa8aLM96YoZdFtwo4ZfnKYLyiBmL3RngrBXPsJBhev
4woUvU0D3Sj3DY9ioFObzJAoxe7Phq86KHDGBJwJigz00X8tnmbfJLQiCRHHDmnE
hvISvzv2igV34KEb5SlOONgkvtCDk9aQZzL4oW4DZBTSA1E8cWMIj8efML5xT4Pc
Th9aZRM8vgywX/0QHPhCEhTlPOIru8f4+b4cMM2m9ZFt76R0kPpQiJtSxxcB4APs
24+XA9sqkGw=
=PF6p
-----END PGP SIGNATURE-----

--=-t54hC5KI/hEpYFP/NvQN--
