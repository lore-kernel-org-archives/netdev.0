From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbevf: Remove the ring adapter pointer value
Date: Thu, 15 Nov 2012 06:39:42 -0800
Message-ID: <1352990387-3872-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59047 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993469Ab2KOOjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:54 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

It is unused - remove it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 1211fa0..dbdf39b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -58,7 +58,6 @@ struct ixgbevf_ring {
 	struct ixgbevf_ring *next;
 	struct net_device *netdev;
 	struct device *dev;
-	struct ixgbevf_adapter *adapter;  /* backlink */
 	void *desc;			/* descriptor ring memory */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
-- 
1.7.11.7
