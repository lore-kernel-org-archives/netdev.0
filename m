From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 07/10] headers, tipc: Add missing #include to
 <linux/tipc_config.h> for userland
Date: Thu, 25 Aug 2011 05:45:14 +0100
Message-ID: <1314247515.27179.124.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SinB/wyfWDmcmTEBoNPr"
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37161 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885Ab1HYEpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:45:17 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SinB/wyfWDmcmTEBoNPr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<linux/tipc_config.h> defines inline functions using ntohs() etc.
For userland these are defined in <arpa/inet.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/tipc_config.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 0db2395..9730b0e 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -41,6 +41,10 @@
 #include <linux/string.h>
 #include <asm/byteorder.h>
=20
+#ifndef __KERNEL__
+#include <arpa/inet.h> /* for ntohs etc. */
+#endif
+
 /*
  * Configuration
  *
--=20
1.7.5.4




--=-SinB/wyfWDmcmTEBoNPr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTWue/yOyVhhEJAQqq3Q/+MQnseeXC+fIa532eW7AKIJViEPQGm2O1
kNtzhbWSYE8fHS7XMeZ0cCNU1x+DU+FXkKlRK6CfioAZfoubrY6DSeFJgUETpzrT
G1cV9mCPnVTTQxXWW1jbI7chVciglb0SNxIYUlyYaoizVQs2VXurtu58ul6jujK2
i+kneXc/sqtiLnv9kDYeqHs0sRjQ+xJLkKtti07oiQfK9JEt7aMzo1jv+uG/JpHL
8buVbM7Ir6P67CvCba7D/R58kLMLsq5Qnob0fNkyTPhrQpDBa497UbV5xIl4Y8Zx
doERfR8793BqP2kUnKz7InPhwYZs5VYwz/x/jOa5vZRTYeR7zO32qVrjr1H6r8jw
PIIzCj0AAUjOXSkTP5QF9vlg8SJypacvLou7bpJbqXwaM9v/yNpHHGNoDJKubC4y
TgrmTI+TmRHZVY27sjw4TY92RFD2zZCCLIyI+wwpQK2eRCcuzd2QpeSvsseHOGXq
t1gImyJct9xYcibUsirdp2iwkzJjUa45SLFhVQVe00tgtE9dNX/EVpZnZcBaIaMm
F1D/n8lBsQsJo2jmB16+TJU093GIEhR7YRoDOWFBd+FPS+SuS/PZjUX3pjHRcscv
4EK1a1VwzCDaXMPqwECSELgWw3Rcg3bfJ0zudSzPkzu2G9aSN8lN75dOolJ9FNAR
R9jUTFsdCzA=
=66bT
-----END PGP SIGNATURE-----

--=-SinB/wyfWDmcmTEBoNPr--
