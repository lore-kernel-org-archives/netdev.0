From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/16] batman-adv: checkpatch - spaces preferred around that '*'
Date: Fri, 29 May 2015 11:05:25 +0200
Message-ID: <1432890328-8247-14-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:46393 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755784AbbE2Jaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:30:52 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.h           | 2 +-
 net/batman-adv/network-coding.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 11d2d9f..026ba37 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -44,7 +44,7 @@
 #define BATADV_TT_CLIENT_TEMP_TIMEOUT 600000 /* in milliseconds */
 #define BATADV_TT_WORK_PERIOD 5000 /* 5 seconds */
 #define BATADV_ORIG_WORK_PERIOD 1000 /* 1 second */
-#define BATADV_DAT_ENTRY_TIMEOUT (5*60000) /* 5 mins in milliseconds */
+#define BATADV_DAT_ENTRY_TIMEOUT (5 * 60000) /* 5 mins in milliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size)
  */
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 4cb70bb..b984bc4 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -275,7 +275,7 @@ static bool batadv_nc_to_purge_nc_path_decoding(struct batadv_priv *bat_priv,
 	 * max_buffer time
 	 */
 	return batadv_has_timed_out(nc_path->last_valid,
-				    bat_priv->nc.max_buffer_time*10);
+				    bat_priv->nc.max_buffer_time * 10);
 }
 
 /**
-- 
2.4.2
