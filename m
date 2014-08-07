From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 1/3] amd: xgbe: fix duplicate #include of linux/phy.h
Date: Thu,  7 Aug 2014 06:50:43 -0600
Message-ID: <1407415846-10277-1-git-send-email-sakiwit@gmail.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34247 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252AbaHGMu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 08:50:58 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so5182521pdb.38
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 05:50:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The header linux/phy.h was included twice, so delete one of them.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 1f5487f4888c..dc84f7193c2d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -115,11 +115,10 @@
  */
 
 #include <linux/spinlock.h>
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
-#include <linux/phy.h>
 #include <net/busy_poll.h>
 #include <linux/clk.h>
 #include <linux/if_ether.h>
 #include <linux/net_tstamp.h>
 #include <linux/phy.h>
