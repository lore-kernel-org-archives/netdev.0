From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/5] irnet: ppp: move IRNET_MINOR to include/linux/miscdevice.h
Date: Thu, 15 Dec 2016 11:42:48 +0100
Message-ID: <20161215104250.16813-3-clabbe.montjoie@gmail.com>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch move the define for IRNET_MINOR to include/linux/miscdevice.h
It is better that all minor number definitions are in the same place.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 include/linux/miscdevice.h | 1 +
 net/irda/irnet/irnet_ppp.h | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index 18b2e3b..5ea0a65 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -37,6 +37,7 @@
 #define HWRNG_MINOR		183
 #define MICROCODE_MINOR		184
 #define KEYPAD_MINOR		185
+#define IRNET_MINOR		187
 #define D7S_MINOR		193
 #define VFIO_MINOR		196
 #define TUN_MINOR		200
diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index 693ebc0..18fcead 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -21,7 +21,6 @@
 
 /* /dev/irnet file constants */
 #define IRNET_MAJOR	10	/* Misc range */
-#define IRNET_MINOR	187	/* Official allocation */
 
 /* IrNET control channel stuff */
 #define IRNET_MAX_COMMAND	256	/* Max length of a command line */
-- 
2.10.2
