From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 1/5] ray_cs: Remove dependency on ieee80211
Date: Sun, 23 Jul 2006 20:37:19 -0700
Message-ID: <200607232037.24803.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2324945.Bou9h2IU9l";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	corey@world.std.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:41702 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751386AbWGXDyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:09 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2324945.Bou9h2IU9l
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

ray_cs: Remove dependency on ieee80211

This patch removes the dependency on ieee80211.h from
the ray_cs driver.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/ray_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 61b83a5..8e112d1 100644
=2D-- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -52,8 +52,8 @@ #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
 #include <pcmcia/mem_op.h>
=20
=2D#include <net/ieee80211.h>
 #include <linux/wireless.h>
+#include <net/iw_handler.h>
=20
 #include <asm/io.h>
 #include <asm/system.h>

--nextPart2324945.Bou9h2IU9l
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExEB0T3Oqt9AH4aERAhgbAJ0ewKKb4JfSLOX/oZHQUZ4IyXyNEwCgxmSI
hsfTZap171X/5I6qM1K6FMY=
=kRDf
-----END PGP SIGNATURE-----

--nextPart2324945.Bou9h2IU9l--
