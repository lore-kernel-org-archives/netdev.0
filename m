From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 02/19] batman-adv: Document optional batadv_algo_ops
Date: Fri, 12 Aug 2016 10:56:38 +0200
Message-ID: <1470992215-11009-3-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:34959 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcHLI5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:06 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Some operations in batadv_algo_ops are optional and marked as such in the
kerneldoc. But some of them miss the "(optional)" in their kerneldoc. These
have to also be marked to give an implementor of an algorithm the correct
background information without looking in the code calling these function
pointers.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/types.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index a64522c..0ede27a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1396,6 +1396,7 @@ struct batadv_forw_packet {
 /**
  * struct batadv_algo_iface_ops - mesh algorithm callbacks (interface specific)
  * @activate: start routing mechanisms when hard-interface is brought up
+ *  (optional)
  * @enable: init routing info when hard-interface is enabled
  * @disable: de-init routing info when hard-interface is disabled
  * @update_mac: (re-)init mac addresses of the protocol information
@@ -1413,6 +1414,7 @@ struct batadv_algo_iface_ops {
 /**
  * struct batadv_algo_neigh_ops - mesh algorithm callbacks (neighbour specific)
  * @hardif_init: called on creation of single hop entry
+ *  (optional)
  * @cmp: compare the metrics of two neighbors for their respective outgoing
  *  interfaces
  * @is_similar_or_better: check if neigh1 is equally similar or better than
@@ -1435,11 +1437,11 @@ struct batadv_algo_neigh_ops {
 /**
  * struct batadv_algo_orig_ops - mesh algorithm callbacks (originator specific)
  * @free: free the resources allocated by the routing algorithm for an orig_node
- *  object
+ *  object (optional)
  * @add_if: ask the routing algorithm to apply the needed changes to the
- *  orig_node due to a new hard-interface being added into the mesh
+ *  orig_node due to a new hard-interface being added into the mesh (optional)
  * @del_if: ask the routing algorithm to apply the needed changes to the
- *  orig_node due to an hard-interface being removed from the mesh
+ *  orig_node due to an hard-interface being removed from the mesh (optional)
  * @print: print the originator table (optional)
  */
 struct batadv_algo_orig_ops {
-- 
2.8.1
