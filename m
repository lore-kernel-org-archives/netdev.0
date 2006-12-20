From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] d80211: allow migration to ieee80211_dev
Date: Wed, 20 Dec 2006 01:31:17 -0500
Message-ID: <200612200131.22776.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6047511.lIr4HQNP25";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:20129 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964913AbWLTGbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 01:31:44 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6047511.lIr4HQNP25
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: allow migration to ieee80211_dev

This patch allows drivers to switch from ieee80211_hw to ieee80211_dev befo=
re=20
we really rename ieee80211_hw and break everything.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 65a5d36..f5de509 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -452,6 +452,9 @@ typedef enum {
 	SET_KEY, DISABLE_KEY, REMOVE_ALL_KEYS,
 } set_key_cmd;
=20
+/* Will go away once ieee80211_hw is really renamed to ieee80211_dev.
+   Please use ieee80211_dev in your driver. */
+#define ieee80211_dev ieee80211_hw
 /* This is driver-visible part of the per-hw state the stack keeps. */
 struct ieee80211_hw {
 	/* these are assigned by d80211, don't write */

--nextPart6047511.lIr4HQNP25
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFiNi6T3Oqt9AH4aERAu7OAJ9v67qm6sd9HYPM1C5D4OaGiK8xOgCeKwbe
IYnurMAMp02s4iIYMXrjHiM=
=XtI5
-----END PGP SIGNATURE-----

--nextPart6047511.lIr4HQNP25--
