From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ibmvnic: Remove unused net_stats member from struct ibmvnic_adapter
Date: Mon, 27 Mar 2017 08:56:59 +0200
Message-ID: <20170327065659.27307-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51204 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751746AbdC0G5D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 02:57:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibmvnic driver keeps its statistics in net_device->stats, so the
net_stats member in struct ibmvnic_adapter is unused. Remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ibm/ibmvnic.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 10ad259208cb..42ad648c174d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -953,7 +953,6 @@ struct ibmvnic_adapter {
 	dma_addr_t bounce_buffer_dma;
 
 	/* Statistics */
-	struct net_device_stats net_stats;
 	struct ibmvnic_statistics stats;
 	dma_addr_t stats_token;
 	struct completion stats_done;
-- 
2.11.0
