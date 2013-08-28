From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/4] batman-adv: move enum definition at the top of the file
Date: Wed, 28 Aug 2013 13:28:09 +0200
Message-ID: <1377689291-2412-3-git-send-email-ordex@autistici.org>
References: <1377689291-2412-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:54814 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab3H1Lc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:32:27 -0400
In-Reply-To: <1377689291-2412-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 9886a2f..0a8a80c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -28,6 +28,22 @@
 #include "bat_algo.h"
 #include "network-coding.h"
 
+
+/**
+ * batadv_dup_status - duplicate status
+ * @BATADV_NO_DUP: the packet is a duplicate
+ * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
+ *  neighbor)
+ * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
+ * @BATADV_PROTECTED: originator is currently protected (after reboot)
+ */
+enum batadv_dup_status {
+	BATADV_NO_DUP = 0,
+	BATADV_ORIG_DUP,
+	BATADV_NEIGH_DUP,
+	BATADV_PROTECTED,
+};
+
 /**
  * batadv_ring_buffer_set - update the ring buffer with the given value
  * @lq_recv: pointer to the ring buffer
@@ -71,21 +87,6 @@ static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
 	return (uint8_t)(sum / count);
 }
 
-/*
- * batadv_dup_status - duplicate status
- * @BATADV_NO_DUP: the packet is a duplicate
- * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
- *  neighbor)
- * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
- * @BATADV_PROTECTED: originator is currently protected (after reboot)
- */
-enum batadv_dup_status {
-	BATADV_NO_DUP = 0,
-	BATADV_ORIG_DUP,
-	BATADV_NEIGH_DUP,
-	BATADV_PROTECTED,
-};
-
 static struct batadv_neigh_node *
 batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			const uint8_t *neigh_addr,
-- 
1.8.1.5
