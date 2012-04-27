From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 1/4] e1000: add transmit timestamping support
Date: Fri, 27 Apr 2012 15:04:04 -0400
Message-ID: <1335553447-11964-2-git-send-email-willemb@google.com>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:41166 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116Ab2D0TEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 15:04:10 -0400
Received: by ghbz15 with SMTP id z15so117237ghb.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 12:04:09 -0700 (PDT)
In-Reply-To: <1335553447-11964-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3d712f2..40438ea 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3261,6 +3261,8 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	                     nr_frags, mss);
 
 	if (count) {
+		skb_tx_timestamp(skb);
+
 		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
-- 
1.7.7.3
