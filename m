From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/12] batman-adv: Distributed ARP Table - add a new debug log level
Date: Wed,  7 Nov 2012 20:11:34 +0100
Message-ID: <1352315502-20324-5-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44661 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab2KGTMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:33 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new log level has been added to concentrate messages regarding DAT: ARP
snooping, requests, response and DHT related messages.
The new log level is named BATADV_DBG_DAT

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/networking/batman-adv.txt | 3 ++-
 net/batman-adv/main.h                   | 4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index a173d2a..c1d8204 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -203,7 +203,8 @@ abled  during run time. Following log_levels are defined:
 2 - Enable messages related to route added / changed / deleted
 4 - Enable messages related to translation table operations
 8 - Enable messages related to bridge loop avoidance
-15 - enable all messages
+16 - Enable messaged related to DAT, ARP snooping and parsing
+31 - Enable all messages
 
 The debug output can be changed at runtime  using  the  file
 /sys/class/net/bat0/mesh/log_level. e.g.
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 897ba6a..c08724a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -171,6 +171,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
  * @BATADV_DBG_ROUTES: route added / changed / deleted
  * @BATADV_DBG_TT: translation table messages
  * @BATADV_DBG_BLA: bridge loop avoidance messages
+ * @BATADV_DBG_DAT: ARP snooping and DAT related messages
  * @BATADV_DBG_ALL: the union of all the above log levels
  */
 enum batadv_dbg_level {
@@ -178,7 +179,8 @@ enum batadv_dbg_level {
 	BATADV_DBG_ROUTES = BIT(1),
 	BATADV_DBG_TT	  = BIT(2),
 	BATADV_DBG_BLA    = BIT(3),
-	BATADV_DBG_ALL    = 15,
+	BATADV_DBG_DAT    = BIT(4),
+	BATADV_DBG_ALL    = 31,
 };
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-- 
1.8.0
