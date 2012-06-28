From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/18] batman-adv: Prefix sysfs defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:19 +0200
Message-ID: <1340876067-28333-11-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30235 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932780Ab2F1Jed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:33 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c |   14 +++++++-------
 net/batman-adv/bat_sysfs.h |    4 ++--
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 3862fe1..725e7d7 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -505,11 +505,11 @@ int batadv_sysfs_add_meshif(struct net_device *de=
v)
 	struct bat_attribute **bat_attr;
 	int err;
=20
-	bat_priv->mesh_obj =3D kobject_create_and_add(SYSFS_IF_MESH_SUBDIR,
+	bat_priv->mesh_obj =3D kobject_create_and_add(BATADV_SYSFS_IF_MESH_SU=
BDIR,
 						    batif_kobject);
 	if (!bat_priv->mesh_obj) {
 		batadv_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
-			   SYSFS_IF_MESH_SUBDIR);
+			   BATADV_SYSFS_IF_MESH_SUBDIR);
 		goto out;
 	}
=20
@@ -518,7 +518,7 @@ int batadv_sysfs_add_meshif(struct net_device *dev)
 					&((*bat_attr)->attr));
 		if (err) {
 			batadv_err(dev, "Can't add sysfs file: %s/%s/%s\n",
-				   dev->name, SYSFS_IF_MESH_SUBDIR,
+				   dev->name, BATADV_SYSFS_IF_MESH_SUBDIR,
 				   ((*bat_attr)->attr).name);
 			goto rem_attr;
 		}
@@ -673,12 +673,12 @@ int batadv_sysfs_add_hardif(struct kobject **hard=
if_obj, struct net_device *dev)
 	struct bat_attribute **bat_attr;
 	int err;
=20
-	*hardif_obj =3D kobject_create_and_add(SYSFS_IF_BAT_SUBDIR,
-						    hardif_kobject);
+	*hardif_obj =3D kobject_create_and_add(BATADV_SYSFS_IF_BAT_SUBDIR,
+					     hardif_kobject);
=20
 	if (!*hardif_obj) {
 		batadv_err(dev, "Can't add sysfs directory: %s/%s\n", dev->name,
-			   SYSFS_IF_BAT_SUBDIR);
+			   BATADV_SYSFS_IF_BAT_SUBDIR);
 		goto out;
 	}
=20
@@ -686,7 +686,7 @@ int batadv_sysfs_add_hardif(struct kobject **hardif=
_obj, struct net_device *dev)
 		err =3D sysfs_create_file(*hardif_obj, &((*bat_attr)->attr));
 		if (err) {
 			batadv_err(dev, "Can't add sysfs file: %s/%s/%s\n",
-				   dev->name, SYSFS_IF_BAT_SUBDIR,
+				   dev->name, BATADV_SYSFS_IF_BAT_SUBDIR,
 				   ((*bat_attr)->attr).name);
 			goto rem_attr;
 		}
diff --git a/net/batman-adv/bat_sysfs.h b/net/batman-adv/bat_sysfs.h
index 3672277..23a8390 100644
--- a/net/batman-adv/bat_sysfs.h
+++ b/net/batman-adv/bat_sysfs.h
@@ -20,8 +20,8 @@
 #ifndef _NET_BATMAN_ADV_SYSFS_H_
 #define _NET_BATMAN_ADV_SYSFS_H_
=20
-#define SYSFS_IF_MESH_SUBDIR "mesh"
-#define SYSFS_IF_BAT_SUBDIR "batman_adv"
+#define BATADV_SYSFS_IF_MESH_SUBDIR "mesh"
+#define BATADV_SYSFS_IF_BAT_SUBDIR "batman_adv"
=20
 struct bat_attribute {
 	struct attribute attr;
--=20
1.7.9.4
