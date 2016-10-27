From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 05/17] batman-adv: Document new nc, mcast and tpmeter log levels
Date: Thu, 27 Oct 2016 21:01:38 +0200
Message-ID: <20161027190150.7880-6-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38348 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942162AbcJ0TB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:57 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 Documentation/networking/batman-adv.txt | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index a918131..ccf9467 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -161,13 +161,16 @@ file in debugfs
 The additional debug output is by default disabled. It can be en-
 abled  during run time. Following log_levels are defined:
 
-0 - All  debug  output  disabled
-1 - Enable messages related to routing / flooding / broadcasting
-2 - Enable messages related to route added / changed / deleted
-4 - Enable messages related to translation table operations
-8 - Enable messages related to bridge loop avoidance
-16 - Enable messaged related to DAT, ARP snooping and parsing
-31 - Enable all messages
+  0 - All  debug  output  disabled
+  1 - Enable messages related to routing / flooding / broadcasting
+  2 - Enable messages related to route added / changed / deleted
+  4 - Enable messages related to translation table operations
+  8 - Enable messages related to bridge loop avoidance
+ 16 - Enable messages related to DAT, ARP snooping and parsing
+ 32 - Enable messages related to network coding
+ 64 - Enable messages related to multicast
+128 - Enable messages related to throughput meter
+255 - Enable all messages
 
 The debug output can be changed at runtime  using  the  file
 /sys/class/net/bat0/mesh/log_level. e.g.
-- 
2.10.1
