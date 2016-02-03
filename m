From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 10/16] batman-adv: fix kerneldoc for DAT functions
Date: Wed,  3 Feb 2016 10:18:31 +0800
Message-ID: <1454465917-13332-11-git-send-email-a@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:10381 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755508AbcBCCku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:50 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/distributed-arp-table.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 2f13429ce5d3..60df82385495 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -741,6 +741,8 @@ static void batadv_dat_hash_free(struct batadv_priv *bat_priv)
 /**
  * batadv_dat_init - initialise the DAT internals
  * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: 0 in case of success, a negative error code otherwise
  */
 int batadv_dat_init(struct batadv_priv *bat_priv)
 {
@@ -779,6 +781,8 @@ void batadv_dat_free(struct batadv_priv *bat_priv)
  * batadv_dat_cache_seq_print_text - print the local DAT hash table
  * @seq: seq file to print on
  * @offset: not used
+ *
+ * Return: always 0
  */
 int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 {
-- 
2.7.0
