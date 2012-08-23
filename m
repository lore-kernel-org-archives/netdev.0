From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/18] batman-adv: fix typos in comments
Date: Thu, 23 Aug 2012 15:10:17 +0200
Message-ID: <1345727427-20805-9-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28737 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202Ab2HWNKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:55 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the word millisecond is misspelled in several comments. This patch fixes it.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h |    8 ++++----
 net/batman-adv/vis.h  |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 5d8fa07..4dfeae5 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -41,13 +41,13 @@
  * -> TODO: check influence on BATADV_TQ_LOCAL_WINDOW_SIZE
  */
 #define BATADV_PURGE_TIMEOUT 200000 /* 200 seconds */
-#define BATADV_TT_LOCAL_TIMEOUT 3600000 /* in miliseconds */
-#define BATADV_TT_CLIENT_ROAM_TIMEOUT 600000 /* in miliseconds */
+#define BATADV_TT_LOCAL_TIMEOUT 3600000 /* in milliseconds */
+#define BATADV_TT_CLIENT_ROAM_TIMEOUT 600000 /* in milliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size)
  */
 #define BATADV_TQ_LOCAL_WINDOW_SIZE 64
-/* miliseconds we have to keep pending tt_req */
+/* milliseconds we have to keep pending tt_req */
 #define BATADV_TT_REQUEST_TIMEOUT 3000
 
 #define BATADV_TQ_GLOBAL_WINDOW_SIZE 5
@@ -59,7 +59,7 @@
 #define BATADV_TT_OGM_APPEND_MAX 3
 
 /* Time in which a client can roam at most ROAMING_MAX_COUNT times in
- * miliseconds
+ * milliseconds
  */
 #define BATADV_ROAMING_MAX_TIME 20000
 #define BATADV_ROAMING_MAX_COUNT 5
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
index 84e716e..873282f 100644
--- a/net/batman-adv/vis.h
+++ b/net/batman-adv/vis.h
@@ -20,7 +20,7 @@
 #ifndef _NET_BATMAN_ADV_VIS_H_
 #define _NET_BATMAN_ADV_VIS_H_
 
-/* timeout of vis packets in miliseconds */
+/* timeout of vis packets in milliseconds */
 #define BATADV_VIS_TIMEOUT		200000
 
 int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
-- 
1.7.9.4
