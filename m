From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 3/4] bnx2x: add transmit timestamping support
Date: Fri, 27 Apr 2012 15:04:06 -0400
Message-ID: <1335553447-11964-4-git-send-email-willemb@google.com>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:56906 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116Ab2D0TEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 15:04:14 -0400
Received: by wgbdt11 with SMTP id dt11so58677wgb.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 12:04:12 -0700 (PDT)
In-Reply-To: <1335553447-11964-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 60d5b54..afa6cbb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2953,6 +2953,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netdev_tx_sent_queue(txq, skb->len);
 
+	skb_tx_timestamp(skb);
+
 	txdata->tx_pkt_prod++;
 	/*
 	 * Make sure that the BD data is updated before updating the producer
-- 
1.7.7.3
