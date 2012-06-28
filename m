From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/18] batman-adv: Prefix debugfs defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:18 +0200
Message-ID: <1340876067-28333-10-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30183 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778Ab2F1Jec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:32 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c |    2 +-
 net/batman-adv/bat_debugfs.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.=
c
index ce84a61..f9af65e 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -311,7 +311,7 @@ void batadv_debugfs_init(void)
 	struct bat_debuginfo *bat_debug;
 	struct dentry *file;
=20
-	batadv_debugfs =3D debugfs_create_dir(DEBUGFS_BAT_SUBDIR, NULL);
+	batadv_debugfs =3D debugfs_create_dir(BATADV_DEBUGFS_SUBDIR, NULL);
 	if (batadv_debugfs =3D=3D ERR_PTR(-ENODEV))
 		batadv_debugfs =3D NULL;
=20
diff --git a/net/batman-adv/bat_debugfs.h b/net/batman-adv/bat_debugfs.=
h
index eb0d576..3319e1f 100644
--- a/net/batman-adv/bat_debugfs.h
+++ b/net/batman-adv/bat_debugfs.h
@@ -20,7 +20,7 @@
 #ifndef _NET_BATMAN_ADV_DEBUGFS_H_
 #define _NET_BATMAN_ADV_DEBUGFS_H_
=20
-#define DEBUGFS_BAT_SUBDIR "batman_adv"
+#define BATADV_DEBUGFS_SUBDIR "batman_adv"
=20
 void batadv_debugfs_init(void);
 void batadv_debugfs_destroy(void);
--=20
1.7.9.4
