From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 7/7] ucc_geth: version 1.1
Date: Fri, 13 Apr 2007 01:26:36 -0500
Message-ID: <20070413012636.6d481577.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:39552 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ucc_geth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 20bc105..16b9acd 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -46,8 +46,9 @@
 
 #undef DEBUG
 
-#define DRV_DESC "QE UCC Gigabit Ethernet Controller version:Sept 11, 2006"
+#define DRV_DESC "QE UCC Gigabit Ethernet Controller"
 #define DRV_NAME "ucc_geth"
+#define DRV_VERSION "1.1"
 
 #define ugeth_printk(level, format, arg...)  \
         printk(level format "\n", ## arg)
@@ -4006,4 +4007,5 @@ module_exit(ucc_geth_exit);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION(DRV_DESC);
+MODULE_VERSION(DRV_VERSION);
 MODULE_LICENSE("GPL");
-- 
1.5.0.1

