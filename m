From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/18] batman-adv: Prefix icmp_socket defines with BATADV_
Date: Thu, 28 Jun 2012 11:34:22 +0200
Message-ID: <1340876067-28333-14-git-send-email-ordex@autistici.org>
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
	with ESMTP id S932792Ab2F1Jeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:36 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

Reported-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/icmp_socket.c |    2 +-
 net/batman-adv/icmp_socket.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.=
c
index b285c31..4f45ca7 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -282,7 +282,7 @@ int batadv_socket_setup(struct bat_priv *bat_priv)
 	if (!bat_priv->debug_dir)
 		goto err;
=20
-	d =3D debugfs_create_file(ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
+	d =3D debugfs_create_file(BATADV_ICMP_SOCKET, S_IFREG | S_IWUSR | S_I=
RUSR,
 				bat_priv->debug_dir, bat_priv, &batadv_fops);
 	if (!d)
 		goto err;
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.=
h
index a62ab80..f88f9f0 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -20,7 +20,7 @@
 #ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
 #define _NET_BATMAN_ADV_ICMP_SOCKET_H_
=20
-#define ICMP_SOCKET "socket"
+#define BATADV_ICMP_SOCKET "socket"
=20
 void batadv_socket_init(void);
 int batadv_socket_setup(struct bat_priv *bat_priv);
--=20
1.7.9.4
