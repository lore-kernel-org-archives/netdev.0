From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 04/17] batman-adv: Add dat, mcast, nc and neighbor debugfs files to README
Date: Thu, 27 Oct 2016 21:01:37 +0200
Message-ID: <20161027190150.7880-5-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38338 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935890AbcJ0TBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:55 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 Documentation/networking/batman-adv.txt | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 8afa991..a918131 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -80,9 +80,10 @@ folder:
 There is a special folder for debugging information:
 
 # ls /sys/kernel/debug/batman_adv/bat0/
-# bla_backbone_table  log                 transtable_global
-# bla_claim_table     originators         transtable_local
-# gateways            socket
+# bla_backbone_table  log          neighbors          transtable_local
+# bla_claim_table     mcast_flags  originators
+# dat_cache           nc           socket
+# gateways            nc_nodes     transtable_global
 
 Some of the files contain all sort of status information  regard-
 ing  the  mesh  network.  For  example, you can view the table of
-- 
2.10.1
