From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 2/2] ucc_geth: implement and increment version number
Date: Tue, 10 Apr 2007 16:57:06 -0500
Message-ID: <20070410165706.51dfe79c.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:57054 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbXDJV5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 17:57:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
please consider for 2.6.22

 drivers/net/ucc_geth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1b943e6..c9b1b28 100644
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
@@ -3975,4 +3976,5 @@ module_exit(ucc_geth_exit);
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION(DRV_DESC);
+MODULE_VERSION(DRV_VERSION);
 MODULE_LICENSE("GPL");
-- 
1.5.0.1

