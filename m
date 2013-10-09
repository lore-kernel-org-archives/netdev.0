From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/16] batman-adv: move BATADV_TT_CLIENT_TEMP to higher bit
Date: Wed,  9 Oct 2013 21:32:49 +0200
Message-ID: <1381347174-3629-12-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:30933 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab3JITmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:42:37 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Client flags from bit 0 to 7 are sent over the wire.
BATADV_TT_CLIENT_TEMP is a local flag and is not supposed
to be sent to the network. Therefore it has occupy a
higher bit.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/packet.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 7a337d7..ab3084f 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -106,10 +106,10 @@ enum batadv_tt_client_flags {
 	BATADV_TT_CLIENT_DEL     = BIT(0),
 	BATADV_TT_CLIENT_ROAM    = BIT(1),
 	BATADV_TT_CLIENT_WIFI    = BIT(2),
-	BATADV_TT_CLIENT_TEMP	 = BIT(3),
 	BATADV_TT_CLIENT_NOPURGE = BIT(8),
 	BATADV_TT_CLIENT_NEW     = BIT(9),
 	BATADV_TT_CLIENT_PENDING = BIT(10),
+	BATADV_TT_CLIENT_TEMP	 = BIT(11),
 };
 
 /* claim frame types for the bridge loop avoidance */
-- 
1.8.3.2
