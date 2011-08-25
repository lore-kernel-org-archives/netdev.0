From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 09/10] headers, xtables: Add missing #include
 <linux/netfilter.h>
Date: Thu, 25 Aug 2011 05:45:42 +0100
Message-ID: <1314247543.27179.126.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MXOTR4fj5csVkVE77kH/"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MXOTR4fj5csVkVE77kH/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Various headers use union nf_inet_addr, defined in <linux/netfilter.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_connlimit.h |    1 +
 include/linux/netfilter/xt_conntrack.h |    1 +
 include/linux/netfilter/xt_iprange.h   |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_connlimit.h b/include/linux/netfilt=
er/xt_connlimit.h
index 0ca66e9..d1366f0 100644
--- a/include/linux/netfilter/xt_connlimit.h
+++ b/include/linux/netfilter/xt_connlimit.h
@@ -2,6 +2,7 @@
 #define _XT_CONNLIMIT_H
=20
 #include <linux/types.h>
+#include <linux/netfilter.h>
=20
 struct xt_connlimit_data;
=20
diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilt=
er/xt_conntrack.h
index 74b904d..e3c041d 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -6,6 +6,7 @@
 #define _XT_CONNTRACK_H
=20
 #include <linux/types.h>
+#include <linux/netfilter.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
=20
 #define XT_CONNTRACK_STATE_BIT(ctinfo) (1 << ((ctinfo)%IP_CT_IS_REPLY+1))
diff --git a/include/linux/netfilter/xt_iprange.h b/include/linux/netfilter=
/xt_iprange.h
index c1f21a7..25fd7cf 100644
--- a/include/linux/netfilter/xt_iprange.h
+++ b/include/linux/netfilter/xt_iprange.h
@@ -2,6 +2,7 @@
 #define _LINUX_NETFILTER_XT_IPRANGE_H 1
=20
 #include <linux/types.h>
+#include <linux/netfilter.h>
=20
 enum {
 	IPRANGE_SRC     =3D 1 << 0,	/* match source IP address */
--=20
1.7.5.4




--=-MXOTR4fj5csVkVE77kH/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTdue/yOyVhhEJAQqFhQ//RCwAdwAUepv5ziJCdS3ewEVl5NnW5Xk/
YKSSBJGgIZ/UTRp9efdaDYO25PemrQW74ppoo+eFK32e814JmSSMOGO+HB96aYYn
fIskCLdBoQap70nRLjUMUKw4WMcWwb4to7wJarOMOmiauhK5OaD7RXz2vvH5N55D
1Y46yWGgrp1hotZFCseZRzk87fBQitlbntiCmkhRWrpp1B1PrWTsaEt2Ju0KqEKF
h7ZlRcxXLci0N9VJmZNMsSE4BFbVYmVpzrHQZgUjOErwScGUC/VWm8IB43uRQW8U
gcw47rs7dUikCHZE+k206JUo+n8l8qNBca10lVB0ixWAInOATZhUVuUSS0y6SD+p
ulAa/j+H6321Xqn6o+EkF05GqwfoeGb9HDNFi3uECUAxtSQpBvgdHxrzNxZuYZ61
r0NLf9hUk5NHo9F3T+MsBUKXRULLexTPNnPg/2D7SvsaSjF7sgLsDnk+f6ZvqoUy
M3Y8ggZCTOytJzQuIYFJZ1iPdEd8+MVJyEUPMDLjnLWxoX1diZdHfjzMxjcYzPSU
xmxfWhNaCLhE/59dLaJ/TejcfUGzis+ktHwdBVO+t6SDFPFK3/a4Tcx4EqxMTWw1
J/IzJbEjMell6gpOxM4RIWl3SwBQbQVR0QgSxqavNrHGgJas8TsZZkvdWDe28fj2
Xe4goJKdurQ=
=qbzs
-----END PGP SIGNATURE-----

--=-MXOTR4fj5csVkVE77kH/--
