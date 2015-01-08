From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/15] batman-adv: kernel doc fixes for bat_iv_ogm.c
Date: Thu,  8 Jan 2015 16:15:08 +0100
Message-ID: <1420730120-9844-4-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4917 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256AbbAHPQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:16:30 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1e80539..73209f3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -28,7 +28,7 @@
=20
=20
 /**
- * batadv_dup_status - duplicate status
+ * enum batadv_dup_status - duplicate status
  * @BATADV_NO_DUP: the packet is a duplicate
  * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for=
 the
  *  neighbor)
@@ -517,7 +517,7 @@ out:
  * @bat_priv: the bat priv with all the soft interface information
  * @packet_len: (total) length of the OGM
  * @send_time: timestamp (jiffies) when the packet is to be sent
- * @direktlink: true if this is a direct link packet
+ * @directlink: true if this is a direct link packet
  * @if_incoming: interface where the packet was received
  * @if_outgoing: interface for which the retransmission should be cons=
idered
  * @forw_packet: the forwarded packet which should be checked
@@ -1366,6 +1366,7 @@ out:
 /**
  * batadv_iv_ogm_process_per_outif - process a batman iv OGM for an ou=
tgoing if
  * @skb: the skb containing the OGM
+ * @ogm_offset: offset from skb->data to start of ogm header
  * @orig_node: the (cached) orig node for the originator of this OGM
  * @if_incoming: the interface where this packet was received
  * @if_outgoing: the interface for which the packet should be consider=
ed
@@ -1902,10 +1903,10 @@ out:
  * batadv_iv_ogm_neigh_is_eob - check if neigh1 is equally good or bet=
ter than
  *  neigh2 from the metric prospective
  * @neigh1: the first neighbor object of the comparison
- * @if_outgoing: outgoing interface for the first neighbor
+ * @if_outgoing1: outgoing interface for the first neighbor
  * @neigh2: the second neighbor object of the comparison
  * @if_outgoing2: outgoing interface for the second neighbor
-
+ *
  * Returns true if the metric via neigh1 is equally good or better tha=
n
  * the metric via neigh2, false otherwise.
  */
--=20
2.2.1
