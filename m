From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/19] batman-adv: get rid of pointless cast in memcpy()
Date: Mon, 18 Jun 2012 22:39:13 +0200
Message-ID: <1340051963-14836-10-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41482 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304Ab2FRUjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:11 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>

memcpy() arguments are void *, precisely to avoid that kind of pointless
casts.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5c1ac55..89e2b1c 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -510,7 +510,7 @@ static void bla_send_announce(struct bat_priv *bat_priv,
 
 	memcpy(mac, announce_mac, 4);
 	crc = htons(backbone_gw->crc);
-	memcpy(&mac[4], (uint8_t *)&crc, 2);
+	memcpy(&mac[4], &crc, 2);
 
 	bla_send_claim(bat_priv, mac, backbone_gw->vid, CLAIM_TYPE_ANNOUNCE);
 
-- 
1.7.9.4
