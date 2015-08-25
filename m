From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/15] batman-adv: Fix kerneldoc over 80 column lines
Date: Tue, 25 Aug 2015 13:02:26 +0200
Message-ID: <1440500559-28368-3-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:48382 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237AbbHYLDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:53 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Kerneldoc required single line documentation in the past (before 2009).
Therefore, the 80 columns limit per line check of checkpatch was disabled
for kerneldoc. But kerneldoc is not excluded anymore from it and checkpatch
now enabled the check again.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/icmp_socket.c    | 4 ++--
 net/batman-adv/network-coding.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 5a70b7e..bcabb5e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -337,8 +337,8 @@ err:
 }
 
 /**
- * batadv_socket_receive_packet - schedule an icmp packet to be sent to userspace
- *  on an icmp socket.
+ * batadv_socket_receive_packet - schedule an icmp packet to be sent to
+ *  userspace on an icmp socket.
  * @socket_client: the socket this packet belongs to
  * @icmph: pointer to the header of the icmp packet
  * @icmp_len: total length of the icmp packet
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 60dc7a6..5cab144 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -872,8 +872,8 @@ free:
 }
 
 /**
- * batadv_nc_update_nc_node - updates stored incoming and outgoing nc node structs
- *  (best called on incoming OGMs)
+ * batadv_nc_update_nc_node - updates stored incoming and outgoing nc node
+ *  structs (best called on incoming OGMs)
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node originating the ogm packet
  * @orig_neigh_node: neighboring orig node from which we received the ogm packet
-- 
2.5.0
