From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] dwc_eth_qos: drop duplicate headers
Date: Wed, 23 Nov 2016 22:24:35 +0800
Message-ID: <906a07a7db3f3d6454236dd10d4082c1d9c78fa6.1479905884.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lars Persson <lars.persson@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop duplicate headers types.h and delay.h from dwc_eth_qos.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 7053301..acce385 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -33,7 +33,6 @@
 #include <linux/stat.h>
 #include <linux/types.h>
 
-#include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
@@ -43,7 +42,6 @@
 
 #include <linux/phy.h>
 #include <linux/mii.h>
-#include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
 
-- 
2.9.3
