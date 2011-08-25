From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 03/10] headers, pppol2tp: Use __kernel_pid_t in
 <linux/pppol2tp.h>
Date: Thu, 25 Aug 2011 05:43:50 +0100
Message-ID: <1314247430.27179.120.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TNaleqomPutXNpAAsDva"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37139 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751846Ab1HYEnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:43:50 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TNaleqomPutXNpAAsDva
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<linux/types.h> defines __kernel_pid_t for userland; pid_t is
defined elsewhere (and potentially differently).

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if_pppol2tp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_pppol2tp.h b/include/linux/if_pppol2tp.h
index 184bc55..23cefa1 100644
--- a/include/linux/if_pppol2tp.h
+++ b/include/linux/if_pppol2tp.h
@@ -39,7 +39,7 @@ struct pppol2tp_addr {
  * bits. So we need a different sockaddr structure.
  */
 struct pppol2tpv3_addr {
-	pid_t	pid;			/* pid that owns the fd.
+	__kernel_pid_t	pid;		/* pid that owns the fd.
 					 * 0 =3D> current */
 	int	fd;			/* FD of UDP or IP socket to use */
=20
--=20
1.7.5.4




--=-TNaleqomPutXNpAAsDva
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTBue/yOyVhhEJAQonbQ//fm0yly/0/zlBaIJLIohHj6dXcMvQiWg5
CxIrd5tB3h/SEOKj7kzMCClGZh0PXyRTBFK4CfHI2NsY8khAZMIFtsa3/w2Eng4S
ozKS9DiOQdkiyJp0Ni3yIs3EbLEjoJ+fz4LiUcQ4i3sJp5P9Hgqnu8w5Fwe6891M
Rb68qeyJNpXzKYq+/+EiVPMpQSQIIqbyHUh9FTS6iK6i65Zdj7nYtpdUS2fTmIlz
Mp8LHnOASpl84lZGgFQcNGcJNMjMbBo/fOTYakfF23Sut7nhDf/q40dyUazPWesD
rQuavX08oJzs+3AbfHHaub85+rqzSUhGiTg9QwAK6VqgRmQUbye2fR0Uson/BNLt
B/Jwm2CAbOMEeB7mVNYAxTFWxwARfstxgF6ukyiWsUFkzveh9owo22MhpZ3UBvx/
iP6LnlJTTMQz1/zCb7GtJrOBwAHFECu5hOIZIGInKufZNbMBGYWTwvahZGdsGyi4
Gecppi2A7ZVnB4mpiZc6sGyqzBxA41zLSMGryhTs2YwE/Ri5UQvicn3MPAqCjoDU
POZ7TxtDHe5uI9Ulaviv/5J1QGR9ViV44+u5SPP4EC2/Jb69CojaKKC7617KDZWP
NK2TqElb5jxst5yNGf8JAgMu/yYkvVFx5d4H+aIm+6zZqGmUpMWYz0gBvP8S3LmT
cww0ENg2dcU=
=jbG/
-----END PGP SIGNATURE-----

--=-TNaleqomPutXNpAAsDva--
