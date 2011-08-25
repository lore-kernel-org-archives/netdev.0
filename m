From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 08/10] headers, netfilter: Add missing #include
 <limits.h> for userland
Date: Thu, 25 Aug 2011 05:45:36 +0100
Message-ID: <1314247537.27179.125.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hDG7cx7sua0UEkpO3D0n"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hDG7cx7sua0UEkpO3D0n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Various headers use INT_MIN and INT_MAX, which are defined for
userland in <limits.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_decnet.h |    3 +++
 include/linux/netfilter_ipv4.h   |    3 +++
 include/linux/netfilter_ipv6.h   |    3 +++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter_decnet.h b/include/linux/netfilter_dec=
net.h
index 6f42536..0b09732 100644
--- a/include/linux/netfilter_decnet.h
+++ b/include/linux/netfilter_decnet.h
@@ -11,6 +11,9 @@
=20
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_DN_SRC		0x0001
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.=
h
index 29c7727..fa0946c 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -9,6 +9,9 @@
=20
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_IP_SRC		0x0001
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.=
h
index 1f7e300..57c0251 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -12,6 +12,9 @@
=20
 /* only for userspace compatibility */
 #ifndef __KERNEL__
+
+#include <limits.h> /* for INT_MIN, INT_MAX */
+
 /* IP Cache bits. */
 /* Src IP address. */
 #define NFC_IP6_SRC              0x0001
--=20
1.7.5.4




--=-hDG7cx7sua0UEkpO3D0n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTcOe/yOyVhhEJAQp4cRAArQUlgQb7C9C9mWQZOMtpkvdxnZEmRAyj
+VddUZfp9qBi/K6T+TfHVLptkYDr1hghNSQkvJzldmvZUI2rmDZI8proVLwWtTni
OBE+itDmamiMIf1seuCjzYcaXb4lx9+wshimq30WxYwzR3LSvc34OyFw1ptjc9va
79UlUZhYGpad0XXMARrzFisrKXzTfI0UkK6rn6e4O4zosIJNmEujCyRQH+Zwyiar
uP/mYR3m6kzODXL5CrPu0R7+M5cw4ZZ1w0R7u8Vdn7NNj6Jc+ezefWVRFr9rWRwG
84Im/oNjjQ1C7IpLeX1hJJam7R9XbphMFtclIOBVCoMu98XfFt5QIxMl4mKMbaQc
1X0a+/K6r34GfRtqIPIUNq5LX/5P+hv7RmBXtPNbpyidgEsD2MOinpGYXYhpm271
lTQ0V8/pYw86DbJRgK9JwGsI/EtO9h9m8nwXqpYslafg9HYT0jPp1UOtVPIr/CzE
sbeANAZ1VhI+ErUVeZMAKPQBRIIK5T9GtvbJ4aFTqCbCOAwrV+XD3yYeE8IMhQJU
caD9cRuhrJt4Ej/KHYmo7Ts2kIrQGvHFyCi+Uv+PYOLGkqlSFvC7YEODm3fWpsTp
0EQyw4jN9z71dYyMdL6N0ESJWMC3xcEnpOzRO04BCl70XQgi0IFFQg3Q2VRkrqfL
HLK0Ur7vn3U=
=bGQq
-----END PGP SIGNATURE-----

--=-hDG7cx7sua0UEkpO3D0n--
