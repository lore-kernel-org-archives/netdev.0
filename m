From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/14] batman-adv: add missing sysfs attributes to README
Date: Mon, 13 Jan 2014 23:31:34 +0100
Message-ID: <1389652298-472-11-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:13623 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbaAMWx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:53:57 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing sysfs attributes in the proper section of the README

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 Documentation/networking/batman-adv.txt | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 89490beb..58e4904 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -66,11 +66,10 @@ All  mesh  wide  settings  can be found in batman's own interface
 folder:
 
 # ls /sys/class/net/bat0/mesh/
-# aggregated_ogms        gw_bandwidth           log_level
-# ap_isolation           gw_mode                orig_interval
-# bonding                gw_sel_class           routing_algo
-# bridge_loop_avoidance  hop_penalty            fragmentation
-
+#aggregated_ogms        distributed_arp_table  gw_sel_class    orig_interval
+#ap_isolation           fragmentation          hop_penalty     routing_algo
+#bonding                gw_bandwidth           isolation_mark  vlan0
+#bridge_loop_avoidance  gw_mode                log_level
 
 There is a special folder for debugging information:
 
-- 
1.8.5.2
