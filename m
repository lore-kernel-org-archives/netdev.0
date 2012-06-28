From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/18] batman-adv: Prefix gateway defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:21 +0200
Message-ID: <1340876067-28333-13-git-send-email-ordex@autistici.org>
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
	with ESMTP id S932778Ab2F1Jef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:35 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_sysfs.c      |   26 +++++++++++++++-----------
 net/batman-adv/gateway_common.h |    6 +++---
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 725e7d7..a6c27f0 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -361,13 +361,16 @@ static ssize_t batadv_show_gw_mode(struct kobject=
 *kobj, struct attribute *attr,
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
 	case GW_MODE_CLIENT:
-		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_CLIENT_NAME);
+		bytes_written =3D sprintf(buff, "%s\n",
+					BATADV_GW_MODE_CLIENT_NAME);
 		break;
 	case GW_MODE_SERVER:
-		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_SERVER_NAME);
+		bytes_written =3D sprintf(buff, "%s\n",
+					BATADV_GW_MODE_SERVER_NAME);
 		break;
 	default:
-		bytes_written =3D sprintf(buff, "%s\n", GW_MODE_OFF_NAME);
+		bytes_written =3D sprintf(buff, "%s\n",
+					BATADV_GW_MODE_OFF_NAME);
 		break;
 	}
=20
@@ -386,15 +389,16 @@ static ssize_t batadv_store_gw_mode(struct kobjec=
t *kobj,
 	if (buff[count - 1] =3D=3D '\n')
 		buff[count - 1] =3D '\0';
=20
-	if (strncmp(buff, GW_MODE_OFF_NAME, strlen(GW_MODE_OFF_NAME)) =3D=3D =
0)
+	if (strncmp(buff, BATADV_GW_MODE_OFF_NAME,
+		    strlen(BATADV_GW_MODE_OFF_NAME)) =3D=3D 0)
 		gw_mode_tmp =3D GW_MODE_OFF;
=20
-	if (strncmp(buff, GW_MODE_CLIENT_NAME,
-		    strlen(GW_MODE_CLIENT_NAME)) =3D=3D 0)
+	if (strncmp(buff, BATADV_GW_MODE_CLIENT_NAME,
+		    strlen(BATADV_GW_MODE_CLIENT_NAME)) =3D=3D 0)
 		gw_mode_tmp =3D GW_MODE_CLIENT;
=20
-	if (strncmp(buff, GW_MODE_SERVER_NAME,
-		    strlen(GW_MODE_SERVER_NAME)) =3D=3D 0)
+	if (strncmp(buff, BATADV_GW_MODE_SERVER_NAME,
+		    strlen(BATADV_GW_MODE_SERVER_NAME)) =3D=3D 0)
 		gw_mode_tmp =3D GW_MODE_SERVER;
=20
 	if (gw_mode_tmp < 0) {
@@ -409,13 +413,13 @@ static ssize_t batadv_store_gw_mode(struct kobjec=
t *kobj,
=20
 	switch (atomic_read(&bat_priv->gw_mode)) {
 	case GW_MODE_CLIENT:
-		curr_gw_mode_str =3D GW_MODE_CLIENT_NAME;
+		curr_gw_mode_str =3D BATADV_GW_MODE_CLIENT_NAME;
 		break;
 	case GW_MODE_SERVER:
-		curr_gw_mode_str =3D GW_MODE_SERVER_NAME;
+		curr_gw_mode_str =3D BATADV_GW_MODE_SERVER_NAME;
 		break;
 	default:
-		curr_gw_mode_str =3D GW_MODE_OFF_NAME;
+		curr_gw_mode_str =3D BATADV_GW_MODE_OFF_NAME;
 		break;
 	}
=20
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_c=
ommon.h
index 6f8a4d0..31bbc3c 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -26,9 +26,9 @@ enum gw_modes {
 	GW_MODE_SERVER,
 };
=20
-#define GW_MODE_OFF_NAME	"off"
-#define GW_MODE_CLIENT_NAME	"client"
-#define GW_MODE_SERVER_NAME	"server"
+#define BATADV_GW_MODE_OFF_NAME	"off"
+#define BATADV_GW_MODE_CLIENT_NAME	"client"
+#define BATADV_GW_MODE_SERVER_NAME	"server"
=20
 void batadv_gw_bandwidth_to_kbit(uint8_t gw_class, int *down, int *up)=
;
 ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff=
,
--=20
1.7.9.4
