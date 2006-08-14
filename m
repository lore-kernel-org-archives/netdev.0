From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-2.6] ray_cs: Remove dependency on ieee80211
Date: Sun, 13 Aug 2006 23:27:17 -0700
Message-ID: <200608132327.24363.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2703417.ftNIZoKkcB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:2755 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751876AbWHNG12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 02:27:28 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2703417.ftNIZoKkcB
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

(This patch was originally sent as part of the patch series that converted=
=20
drivers using ieee80211.h to d80211.h. This patch is still valid because=20
ray_cs does not need ieee80211.h - it needs iw_handler.h. The dependency on=
=20
ieee80211.h was added as part of a build fix patch following the merge of=20
WE-19)

ray_cs: Remove dependency on ieee80211

This patch removes the dependency on ieee80211.h from
the ray_cs driver. ray_cs only needs iw_handler.h.

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

--nextPart2703417.ftNIZoKkcB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE4BfMT3Oqt9AH4aERAtjlAKDXhb0BEMt+JIvKjgxKc/ha/NS4mgCgg+CX
7B4ES8g/yQ2hy28YhJUGU1I=
=kks1
-----END PGP SIGNATURE-----

--nextPart2703417.ftNIZoKkcB--
