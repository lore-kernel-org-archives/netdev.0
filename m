From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 2/6] batman-adv: Remove unnecessary length qualifier in %14pM
Date: Wed,  2 Aug 2017 16:23:18 +0200
Message-ID: <20170802142322.13376-3-sw@simonwunderlich.de>
References: <20170802142322.13376-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Joe Perches <joe@perches.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:46866 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752293AbdHBOXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 10:23:35 -0400
In-Reply-To: <20170802142322.13376-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

It's misleading and unnecessary.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/distributed-arp-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 6930d6b50f99..b6cfa78e9381 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -834,7 +834,7 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 			last_seen_msecs = last_seen_msecs % 60000;
 			last_seen_secs = last_seen_msecs / 1000;
 
-			seq_printf(seq, " * %15pI4 %14pM %4i %6i:%02i\n",
+			seq_printf(seq, " * %15pI4 %pM %4i %6i:%02i\n",
 				   &dat_entry->ip, dat_entry->mac_addr,
 				   batadv_print_vid(dat_entry->vid),
 				   last_seen_mins, last_seen_secs);
-- 
2.11.0
