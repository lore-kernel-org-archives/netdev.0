From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 4/5] irda: irnet: Remove unused IRNET_MAJOR define
Date: Thu, 15 Dec 2016 11:42:49 +0100
Message-ID: <20161215104250.16813-4-clabbe.montjoie@gmail.com>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, samuel@sortiz.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IRNET_MAJOR define is not used, so this patch remove it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/irda/irnet/irnet_ppp.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index 18fcead..ec092c9 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -19,9 +19,6 @@
 
 /************************ CONSTANTS & MACROS ************************/
 
-/* /dev/irnet file constants */
-#define IRNET_MAJOR	10	/* Misc range */
-
 /* IrNET control channel stuff */
 #define IRNET_MAX_COMMAND	256	/* Max length of a command line */
 
-- 
2.10.2
