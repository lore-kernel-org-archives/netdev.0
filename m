From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: ibmveth: Remove unused stats member from struct ibmveth_adapter
Date: Mon, 27 Mar 2017 08:56:15 +0200
Message-ID: <20170327065615.27215-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51180 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751563AbdC0G40 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 02:56:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibmveth driver keeps its statistics in net_device->stats, so the
stats member in struct ibmveth_adapter is unused. Remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ibm/ibmveth.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 7acda04d034e..ed8780cca982 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -146,7 +146,6 @@ struct ibmveth_adapter {
     struct vio_dev *vdev;
     struct net_device *netdev;
     struct napi_struct napi;
-    struct net_device_stats stats;
     unsigned int mcastFilterSize;
     void * buffer_list_addr;
     void * filter_list_addr;
-- 
2.11.0
