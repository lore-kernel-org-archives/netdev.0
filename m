From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 6/7] ixgbe: cleanup variable initialization
Date: Thu, 27 Jan 2011 22:18:54 -0800
Message-ID: <1296195535-2990-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34293 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721Ab1A1GS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 01:18:59 -0500
In-Reply-To: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The ixgbe_fcoe_ddp_get function wasn't initializing one of its variables
and this was producing compiler warnings.  This patch cleans that up.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index ffac3f6..24d74ca 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -165,7 +165,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	unsigned int thisoff = 0;
 	unsigned int thislen = 0;
 	u32 fcbuff, fcdmarw, fcfltrw;
-	dma_addr_t addr;
+	dma_addr_t addr = 0;
 
 	if (!netdev || !sgl)
 		return 0;
-- 
1.7.3.5

