From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] hostap: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:58:52 +0200
Message-ID: <20070205165852.GJ3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jkmaline@cc.hut.fi, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932694AbXBEQ7K@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A patch to use ARRAY_SIZE macro in the Host AP wireless driver.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
Patch is compile tested.

diff --git a/drivers/net/wireless/hostap/hostap.h b/drivers/net/wireless/hostap/hostap.h
index e89c890..ef37a75 100644
--- a/drivers/net/wireless/hostap/hostap.h
+++ b/drivers/net/wireless/hostap/hostap.h
@@ -2,13 +2,14 @@
 #define HOSTAP_H
 
 #include <linux/ethtool.h>
+#include <linux/kernel.h>
 
 #include "hostap_wlan.h"
 #include "hostap_ap.h"
 
 static const long freq_list[] = { 2412, 2417, 2422, 2427, 2432, 2437, 2442,
 				  2447, 2452, 2457, 2462, 2467, 2472, 2484 };
-#define FREQ_COUNT (sizeof(freq_list) / sizeof(freq_list[0]))
+#define FREQ_COUNT ARRAY_SIZE(freq_list)
 
 /* hostap.c */
 

-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
