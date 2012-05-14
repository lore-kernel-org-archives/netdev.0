From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 7/8] batman-adv: README cleanups
Date: Mon, 14 May 2012 09:17:37 +0200
Message-ID: <1336979858-13928-8-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51771 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701Ab2ENHRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:12 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

- Add routing_algo

- Remove date from README:
The date has to be updated when a patch touches the README. Therefore, nearly
every feature will modify this date. It can happens quite often that not only
one feature is currently in development or waiting on the mailinglist. This
creates merge conflicts when applying a patchset.

The date itself doesn't provide any additional information when this file is
only available in a release tarball or as part of a SCM repository.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/networking/batman-adv.txt |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 220a58c..75a5923 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -1,5 +1,3 @@
-[state: 21-08-2011]
-
 BATMAN-ADV
 ----------
 
@@ -68,10 +66,11 @@ All  mesh  wide  settings  can be found in batman's own interface
 folder:
 
 # ls /sys/class/net/bat0/mesh/
-# aggregated_ogms        fragmentation          hop_penalty
-# ap_isolation           gw_bandwidth           log_level
-# bonding                gw_mode                orig_interval
-# bridge_loop_avoidance  gw_sel_class           vis_mode
+# aggregated_ogms        gw_bandwidth           log_level
+# ap_isolation           gw_mode                orig_interval
+# bonding                gw_sel_class           routing_algo
+# bridge_loop_avoidance  hop_penalty            vis_mode
+# fragmentation
 
 
 There is a special folder for debugging information:
-- 
1.7.9.4
