From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] net: wireless: rt2x00: Fixed Spacing issues
Date: Sat, 17 Oct 2015 21:04:39 +0100
Message-ID: <1445112279-27796-1-git-send-email-paulmcquad@gmail.com>
Cc: sgruszka@redhat.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paulmcquad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed empty spaces before/after parenthesis

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/wireless/rt2x00/rt61pci.h | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt61pci.h b/drivers/net/wireless/rt2x00/rt61pci.h
index 1442075..ab86415 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/rt2x00/rt61pci.h
@@ -138,14 +138,14 @@
 #define PAIRWISE_TA_TABLE_BASE		0x1a00
 
 #define SHARED_KEY_ENTRY(__idx) \
-	( SHARED_KEY_TABLE_BASE + \
-		((__idx) * sizeof(struct hw_key_entry)) )
+	(SHARED_KEY_TABLE_BASE + \
+		((__idx) * sizeof(struct hw_key_entry)))
 #define PAIRWISE_KEY_ENTRY(__idx) \
-	( PAIRWISE_KEY_TABLE_BASE + \
-		((__idx) * sizeof(struct hw_key_entry)) )
+	(PAIRWISE_KEY_TABLE_BASE + \
+		((__idx) * sizeof(struct hw_key_entry)))
 #define PAIRWISE_TA_ENTRY(__idx) \
-	( PAIRWISE_TA_TABLE_BASE + \
-		((__idx) * sizeof(struct hw_pairwise_ta_entry)) )
+	(PAIRWISE_TA_TABLE_BASE + \
+		((__idx) * sizeof(struct hw_pairwise_ta_entry)))
 
 struct hw_key_entry {
 	u8 key[16];
@@ -180,7 +180,7 @@ struct hw_pairwise_ta_entry {
 #define HW_BEACON_BASE3			0x2f00
 
 #define HW_BEACON_OFFSET(__index) \
-	( HW_BEACON_BASE0 + (__index * 0x0100) )
+	(HW_BEACON_BASE0 + (__index * 0x0100))
 
 /*
  * HOST-MCU shared memory.
@@ -1287,9 +1287,9 @@ struct hw_pairwise_ta_entry {
 /*
  * DMA descriptor defines.
  */
-#define TXD_DESC_SIZE			( 16 * sizeof(__le32) )
-#define TXINFO_SIZE			( 6 * sizeof(__le32) )
-#define RXD_DESC_SIZE			( 16 * sizeof(__le32) )
+#define TXD_DESC_SIZE			(16 * sizeof(__le32))
+#define TXINFO_SIZE			(6 * sizeof(__le32))
+#define RXD_DESC_SIZE			(16 * sizeof(__le32))
 
 /*
  * TX descriptor format for TX, PRIO and Beacon Ring.
-- 
2.6.1
