From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] ixgbe: Fix format string in ixgbe_fcoe.c
Date: Wed, 15 Jan 2014 01:14:42 +0900
Message-ID: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:55516 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbaANQOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:14:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cppcheck detected following warning in ixgbe_fcoe.c
(warning) %d in format string (no. 1) requires 'int' but the
argument type is 'unsigned int'.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
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
1.8.5.2.309.ga25014b
