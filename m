From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] irttp: Print device parameters and statistics as
 unsigned
Date: Tue, 08 Jun 2010 19:23:01 +0100
Message-ID: <1276021381.2185.58.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44750 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab0FHSXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device statistics have type unsigned long and several of the
device-specific parameters printed here have type __u32.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/irda/irttp.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 47db1d8..285761e 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1853,23 +1853,23 @@ static int irttp_seq_show(struct seq_file *seq, void *v)
 		   self->remote_credit);
 	seq_printf(seq, "send credit: %d\n",
 		   self->send_credit);
-	seq_printf(seq, "  tx packets: %ld, ",
+	seq_printf(seq, "  tx packets: %lu, ",
 		   self->stats.tx_packets);
-	seq_printf(seq, "rx packets: %ld, ",
+	seq_printf(seq, "rx packets: %lu, ",
 		   self->stats.rx_packets);
-	seq_printf(seq, "tx_queue len: %d ",
+	seq_printf(seq, "tx_queue len: %u ",
 		   skb_queue_len(&self->tx_queue));
-	seq_printf(seq, "rx_queue len: %d\n",
+	seq_printf(seq, "rx_queue len: %u\n",
 		   skb_queue_len(&self->rx_queue));
 	seq_printf(seq, "  tx_sdu_busy: %s, ",
 		   self->tx_sdu_busy? "TRUE":"FALSE");
 	seq_printf(seq, "rx_sdu_busy: %s\n",
 		   self->rx_sdu_busy? "TRUE":"FALSE");
-	seq_printf(seq, "  max_seg_size: %d, ",
+	seq_printf(seq, "  max_seg_size: %u, ",
 		   self->max_seg_size);
-	seq_printf(seq, "tx_max_sdu_size: %d, ",
+	seq_printf(seq, "tx_max_sdu_size: %u, ",
 		   self->tx_max_sdu_size);
-	seq_printf(seq, "rx_max_sdu_size: %d\n",
+	seq_printf(seq, "rx_max_sdu_size: %u\n",
 		   self->rx_max_sdu_size);
 
 	seq_printf(seq, "  Used by (%s)\n\n",
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

