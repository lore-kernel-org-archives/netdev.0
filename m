From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 2/2] ucc_geth: Remove unused header
Date: Tue, 31 Mar 2009 08:42:59 -0500
Message-ID: <1238506979-8678-2-git-send-email-galak@kernel.crashing.org>
References: <1238506979-8678-1-git-send-email-galak@kernel.crashing.org>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38195 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757782AbZCaNnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 09:43:09 -0400
In-Reply-To: <1238506979-8678-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the driver is exclusively an of_platform driver we no longer
use the structs and #defines in fsl_devices.h

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/ucc_geth.c         |    1 -
 drivers/net/ucc_geth.h         |    1 -
 drivers/net/ucc_geth_ethtool.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 933fcfb..a124615 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -24,7 +24,6 @@
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/dma-mapping.h>
-#include <linux/fsl_devices.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index e3a25e6..48fde5a 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -20,7 +20,6 @@
 
 #include <linux/kernel.h>
 #include <linux/list.h>
-#include <linux/fsl_devices.h>
 
 #include <asm/immap_qe.h>
 #include <asm/qe.h>
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index a755bea..6fcb500 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -28,7 +28,6 @@
 #include <linux/mm.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
-#include <linux/fsl_devices.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
-- 
1.5.6.6

