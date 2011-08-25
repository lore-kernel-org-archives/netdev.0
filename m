From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 02/10] headers, ax25: Add missing #include to
 <linux/netrom.h>, <linux/rose.h>
Date: Thu, 25 Aug 2011 05:43:18 +0100
Message-ID: <1314247398.27179.119.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-l18VGwDfcfkjRWtCEVMT"
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-l18VGwDfcfkjRWtCEVMT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

These headers use the ax25_address type defined in <linux/ax25.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
---
 include/linux/netrom.h |    2 ++
 include/linux/rose.h   |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netrom.h b/include/linux/netrom.h
index 6939b32..af7313c 100644
--- a/include/linux/netrom.h
+++ b/include/linux/netrom.h
@@ -7,6 +7,8 @@
 #ifndef	NETROM_KERNEL_H
 #define	NETROM_KERNEL_H
=20
+#include <linux/ax25.h>
+
 #define NETROM_MTU	236
=20
 #define NETROM_T1	1
diff --git a/include/linux/rose.h b/include/linux/rose.h
index c7b4b18..e8289cd 100644
--- a/include/linux/rose.h
+++ b/include/linux/rose.h
@@ -7,6 +7,8 @@
 #ifndef	ROSE_KERNEL_H
 #define	ROSE_KERNEL_H
=20
+#include <linux/ax25.h>
+
 #define ROSE_MTU	251
=20
 #define ROSE_MAX_DIGIS 6
--=20
1.7.5.4




--=-l18VGwDfcfkjRWtCEVMT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXS5ue/yOyVhhEJAQqmHg//Zk/knt7UhqxJOFJDFx5IpXTfy+2kkeVQ
3Djo0bKnoBCSIxly7FiuOeGt47C5SMktwwUKxPpA4qwMoW8g5EadkiF9tTPbEYSt
mQQA7HQQEIFeFE/xosXckmX9ZeE9jf03TEXcIAq5OXb4ne+Lj+qU/FaqRk67KMXw
1JfW+icKQDqUJ/jMialQ0tYa4ZYsmAOsccOl26+PVm6zVMMwwP/Az7PQbOZiP4eN
6gcxps4X3jdBPXbW81ISixztcdzdMbXqK8dKk/WLjzrddqmq/582Rk2MiXrewSIV
+INkruJ+PhF2ynbZ8jixjztAzcqiy3BLlkd+Y63Cu6ldaoofg7VAfbL2vr9a0uhl
oqhtL++BjwOUcIef4mlA1cAGoqJo4rn9++TS1leCT/pTS2hirzuwJTQU4y3hR/MX
YM+BIIxoWKTkfxMXd1tGCEK6m8ni9ODs9tSvRgEDxckYSmRRvSuE+bcL1XXfe5bO
TUAD47s5KrjXusgTv581QKPKCRg5uN24s8ObDfPfJCO28+53K2R7yS/aP31TJ7CW
bNok3KRkEtpXmLJCBId7inUN6iQg55FtO4mElRRXbV4CUTKC+Ani3lYbMF/N/4I1
KWBvsfhs3CMSafSwmfl9BkM0/Wd4dRAFhlpw/okvx24JxIa56U4eo1ESrZcpSWju
D5D9wS9SYR8=
=2gAa
-----END PGP SIGNATURE-----

--=-l18VGwDfcfkjRWtCEVMT--
