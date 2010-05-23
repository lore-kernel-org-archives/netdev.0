From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 184/199] drivers/atm/firestream.h: Checkpatch cleanup
Date: Sun, 23 May 2010 22:06:00 +0200
Message-ID: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:28708 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670Ab0EWUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:06:33 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1028570fge.1
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:06:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/atm/firestream.h:2: ERROR: trailing whitespace
drivers/atm/firestream.h:4: ERROR: trailing whitespace
drivers/atm/firestream.h:5: ERROR: trailing whitespace
drivers/atm/firestream.h:6: ERROR: trailing whitespace
drivers/atm/firestream.h:7: ERROR: trailing whitespace
drivers/atm/firestream.h:191: ERROR: trailing whitespace
drivers/atm/firestream.h:221: ERROR: trailing whitespace
drivers/atm/firestream.h:232: ERROR: trailing whitespace
drivers/atm/firestream.h:385: ERROR: trailing whitespace
drivers/atm/firestream.h:458: ERROR: trailing whitespace
drivers/atm/firestream.h:501: ERROR: trailing whitespace
drivers/atm/firestream.h:501: ERROR: code indent should use tabs where possible
drivers/atm/firestream.h:511: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 drivers/atm/firestream.h |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/atm/firestream.h b/drivers/atm/firestream.h
index 49e783e..840befd 100644
--- a/drivers/atm/firestream.h
+++ b/drivers/atm/firestream.h
@@ -1,10 +1,10 @@
 /* drivers/atm/firestream.h - FireStream 155 (MB86697) and
- *                            FireStream  50 (MB86695) device driver 
+ *                            FireStream  50 (MB86695) device driver
  */
- 
-/* Written & (C) 2000 by R.E.Wolff@BitWizard.nl 
- * Copied snippets from zatm.c by Werner Almesberger, EPFL LRC/ICA 
- * and ambassador.c Copyright (C) 1995-1999  Madge Networks Ltd 
+
+/* Written & (C) 2000 by R.E.Wolff@BitWizard.nl
+ * Copied snippets from zatm.c by Werner Almesberger, EPFL LRC/ICA
+ * and ambassador.c Copyright (C) 1995-1999  Madge Networks Ltd
  */
 
 /*
@@ -188,7 +188,7 @@ struct FS_BPENTRY {
  */
 
 
-/* And now for something completely different: 
+/* And now for something completely different:
  * The rest of the registers... */
 
 
@@ -218,7 +218,7 @@ struct FS_BPENTRY {
 #define SARMODE0_ABRVCS_8k  (0x5 << 4)
 #define SARMODE0_ABRVCS_16k (0x6 << 4)
 #define SARMODE0_ABRVCS_32k (0x7 << 4)
-#define SARMODE0_ABRVCS_32  (0x9 << 4) /* The others are "8", this one really has to 
+#define SARMODE0_ABRVCS_32  (0x9 << 4) /* The others are "8", this one really has to
 					  be 9. Tell me you don't believe me. -- REW */
 
 #define SARMODE0_RXVCS_0    (0x0 << 8)
@@ -229,7 +229,7 @@ struct FS_BPENTRY {
 #define SARMODE0_RXVCS_16k  (0x5 << 8)
 #define SARMODE0_RXVCS_32k  (0x6 << 8)
 #define SARMODE0_RXVCS_64k  (0x7 << 8)
-#define SARMODE0_RXVCS_32   (0x8 << 8) 
+#define SARMODE0_RXVCS_32   (0x8 << 8)
 
 #define SARMODE0_CALSUP_1  (0x0 << 12)
 #define SARMODE0_CALSUP_2  (0x1 << 12)
@@ -382,7 +382,7 @@ struct fs_transmit_config {
 #define TC_FLAGS_TRANSPARENT_PAYLOAD (0x1 << 29)
 #define TC_FLAGS_TRANSPARENT_CELL    (0x2 << 29)
 #define TC_FLAGS_STREAMING (0x1 << 28)
-#define TC_FLAGS_PACKET    (0x0) 
+#define TC_FLAGS_PACKET    (0x0)
 #define TC_FLAGS_TYPE_ABR  (0x0 << 22)
 #define TC_FLAGS_TYPE_CBR  (0x1 << 22)
 #define TC_FLAGS_TYPE_VBR  (0x2 << 22)
@@ -455,7 +455,7 @@ struct fs_vcc {
 
 
 struct queue {
-	struct FS_QENTRY *sa, *ea;  
+	struct FS_QENTRY *sa, *ea;
 	int offset;
 };
 
@@ -498,7 +498,7 @@ struct fs_dev {
 #define FS50_CHANNEL_BITS  5
 #define FS50_NR_CHANNELS      (1 << FS50_CHANNEL_BITS)
 
-         
+
 #define FS_DEV(atm_dev) ((struct fs_dev *) (atm_dev)->dev_data)
 #define FS_VCC(atm_vcc) ((struct fs_vcc *) (atm_vcc)->dev_data)
 
@@ -508,7 +508,7 @@ struct fs_dev {
 
 #define IS_FS50(dev)  (dev->flags & FS_IS50)
 #define IS_FS155(dev) (dev->flags & FS_IS155)
- 
+
 /* Within limits this is user-configurable. */
 /* Note: Currently the sum (10 -> 1k channels) is hardcoded in the driver. */
 #define FS155_VPI_BITS 4
-- 
1.7.1.251.gf80a2

