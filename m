From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] e1000e: remove e1000_queue_stats
Date: Mon, 11 Jul 2011 22:00:40 +0200
Message-ID: <1310414440.2860.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49881 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab1GKUAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 16:00:45 -0400
Received: by wyg8 with SMTP id 8so2824905wyg.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 13:00:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct e1000_queue_stats is not used, lets remove it

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/e1000e/e1000.h |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c1e7f94..e9d6e0a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -199,11 +199,6 @@ enum e1000_boards {
 	board_pch2lan,
 };
 
-struct e1000_queue_stats {
-	u64 packets;
-	u64 bytes;
-};
-
 struct e1000_ps_page {
 	struct page *page;
 	u64 dma; /* must be u64 - written to hw */
@@ -257,8 +252,6 @@ struct e1000_ring {
 	int set_itr;
 
 	struct sk_buff *rx_skb_top;
-
-	struct e1000_queue_stats stats;
 };
 
 /* PHY register snapshot values */


