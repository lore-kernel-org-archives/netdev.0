From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/16] batman-adv: Prefix local debugfs structs with batadv_
Date: Mon,  2 Jul 2012 01:43:36 +0200
Message-ID: <1341186226-10549-7-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23572 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab2GAXni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:38 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.=
c
index 4dcda43..bd618e4 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -265,13 +265,13 @@ static int batadv_vis_data_open(struct inode *ino=
de, struct file *file)
 	return single_open(file, batadv_vis_seq_print_text, net_dev);
 }
=20
-struct bat_debuginfo {
+struct batadv_debuginfo {
 	struct attribute attr;
 	const struct file_operations fops;
 };
=20
 #define BATADV_DEBUGINFO(_name, _mode, _open)		\
-struct bat_debuginfo batadv_debuginfo_##_name =3D {	\
+struct batadv_debuginfo batadv_debuginfo_##_name =3D {	\
 	.attr =3D { .name =3D __stringify(_name),		\
 		  .mode =3D _mode, },			\
 	.fops =3D { .owner =3D THIS_MODULE,			\
@@ -294,7 +294,7 @@ static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 			batadv_transtable_local_open);
 static BATADV_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
=20
-static struct bat_debuginfo *batadv_mesh_debuginfos[] =3D {
+static struct batadv_debuginfo *batadv_mesh_debuginfos[] =3D {
 	&batadv_debuginfo_originators,
 	&batadv_debuginfo_gateways,
 	&batadv_debuginfo_transtable_global,
@@ -308,7 +308,7 @@ static struct bat_debuginfo *batadv_mesh_debuginfos=
[] =3D {
=20
 void batadv_debugfs_init(void)
 {
-	struct bat_debuginfo *bat_debug;
+	struct batadv_debuginfo *bat_debug;
 	struct dentry *file;
=20
 	batadv_debugfs =3D debugfs_create_dir(BATADV_DEBUGFS_SUBDIR, NULL);
@@ -340,7 +340,7 @@ void batadv_debugfs_destroy(void)
 int batadv_debugfs_add_meshif(struct net_device *dev)
 {
 	struct bat_priv *bat_priv =3D netdev_priv(dev);
-	struct bat_debuginfo **bat_debug;
+	struct batadv_debuginfo **bat_debug;
 	struct dentry *file;
=20
 	if (!batadv_debugfs)
--=20
1.7.9.4
