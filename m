From: Janusz Wolak <januszwolak@awokados.com.pl>
Subject: [PATCH 3/6] e1000 driver remove checkpatch errors, warnings and checks.
Date: Tue, 13 Oct 2015 23:39:19 +0200
Message-ID: <1444772362-25090-3-git-send-email-januszwolak@awokados.com.pl>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 6970710..ec82b2d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -1,5 +1,5 @@
 /*******************************************************************************
-
+*
   Intel PRO/1000 Linux driver
   Copyright(c) 1999 - 2006 Intel Corporation.
 
@@ -26,7 +26,6 @@
 
 *******************************************************************************/
 
-
 /* Linux PRO/1000 Ethernet Driver main header file */
 
 #ifndef _E1000_H_
@@ -53,7 +52,7 @@
 #include <linux/pagemap.h>
 #include <linux/dma-mapping.h>
 #include <linux/bitops.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/irq.h>
 #include <linux/capability.h>
 #include <linux/in.h>
@@ -82,8 +81,7 @@ struct e1000_adapter;
 
 #define E1000_MAX_INTR			10
 
-/*
- * Count for polling __E1000_RESET condition every 10-20msec.
+/* Count for polling __E1000_RESET condition every 10-20msec.
  */
 #define E1000_CHECK_RESET_COUNT	50
 
-- 
1.9.1
