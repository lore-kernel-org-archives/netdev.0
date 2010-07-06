From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] vxge: show startup message with KERN_INFO
Date: Tue, 6 Jul 2010 21:02:03 +0800
Message-ID: <20100706130203.GA31471@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49424 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755598Ab0GFNCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 09:02:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original KERN_CRIT will mess up terminals.

CC: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/vxge/vxge-main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 45c5dc2..93a9147 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4515,9 +4515,9 @@ vxge_starter(void)
 	char version[32];
 	snprintf(version, 32, "%s", DRV_VERSION);
 
-	printk(KERN_CRIT "%s: Copyright(c) 2002-2009 Neterion Inc\n",
+	printk(KERN_INFO "%s: Copyright(c) 2002-2009 Neterion Inc\n",
 		VXGE_DRIVER_NAME);
-	printk(KERN_CRIT "%s: Driver version: %s\n",
+	printk(KERN_INFO "%s: Driver version: %s\n",
 			VXGE_DRIVER_NAME, version);
 
 	verify_bandwidth();
-- 
1.6.6

