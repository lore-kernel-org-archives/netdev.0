From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 3/4] batman-adv: Use {} braces consistent on the arms of a statement
Date: Sun, 11 Mar 2012 06:44:50 +0800
Message-ID: <1331419491-21333-4-git-send-email-lindner_marek@yahoo.de>
References: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm8-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.238]:48942 "HELO
	nm8-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752224Ab2CJWp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 17:45:59 -0500
In-Reply-To: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 01b66d4..7f8e158 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -237,8 +237,9 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 				"old packet received, start protection\n");
 
 			return 0;
-		} else
+		} else {
 			return 1;
+		}
 	}
 	return 0;
 }
-- 
1.7.9.1
