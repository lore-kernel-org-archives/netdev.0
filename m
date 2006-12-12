From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 1/3] d80211: fix wep.c breakage
Date: Tue, 12 Dec 2006 12:52:36 -0500
Message-ID: <200612121252.41956.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1713169.ETpqtAHRsB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:48080 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932304AbWLLR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 12:56:42 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1713169.ETpqtAHRsB
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: fix wep.c breakage

This patch fixes wep.c, which was broken by Al Viro's severing
skbuff.h -> mm.h patch.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/wep.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index dee8eae..6a96ade 100644
=2D-- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -15,6 +15,7 @@
 #include <linux/crc32.h>
 #include <linux/crypto.h>
 #include <linux/err.h>
+#include <linux/mm.h>
 #include <asm/scatterlist.h>
=20
 #include <net/d80211.h>

--nextPart1713169.ETpqtAHRsB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfuxpT3Oqt9AH4aERAuHFAJsFj7Hsnzqf/zEXCsUEN1CLcZ3K+wCeMklo
a24KUjCzWo1OA/d7Nw6oliw=
=euPp
-----END PGP SIGNATURE-----

--nextPart1713169.ETpqtAHRsB--
