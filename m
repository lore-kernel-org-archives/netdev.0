From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/10] ixgbe: Fix format string in ixgbe_fcoe.c
Date: Wed, 12 Mar 2014 19:31:25 -0700
Message-ID: <1394677890-11043-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54927 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753249AbaCMCb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 22:31:58 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>

cppcheck detected following warning in ixgbe_fcoe.c
(warning) %d in format string (no. 1) requires 'int' but the
argument type is 'unsigned int'.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
Tested-By: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index f58db45..0872617 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -585,7 +585,7 @@ static int ixgbe_fcoe_dma_pool_alloc(struct ixgbe_fcoe *fcoe,
 	struct dma_pool *pool;
 	char pool_name[32];
 
-	snprintf(pool_name, 32, "ixgbe_fcoe_ddp_%d", cpu);
+	snprintf(pool_name, 32, "ixgbe_fcoe_ddp_%u", cpu);
 
 	pool = dma_pool_create(pool_name, dev, IXGBE_FCPTR_MAX,
 			       IXGBE_FCPTR_ALIGN, PAGE_SIZE);
-- 
1.8.3.1
