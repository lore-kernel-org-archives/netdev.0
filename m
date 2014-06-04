From: Antonio Ospite <ao2@ao2.it>
Subject: [PATCH 09/12] trivial: drivers/net/ethernet/nvidia/forcedeth.c: fix typo s/SUBSTRACT1/SUBTRACT1/
Date: Wed,  4 Jun 2014 14:03:47 +0200
Message-ID: <1401883430-19492-10-git-send-email-ao2@ao2.it>
References: <1401883430-19492-1-git-send-email-ao2@ao2.it>
Cc: Antonio Ospite <ao2@ao2.it>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Gordeev <agordeev@redhat.com>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp207.alice.it ([82.57.200.103]:29086 "EHLO smtp207.alice.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbaFDMK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 08:10:27 -0400
In-Reply-To: <1401883430-19492-1-git-send-email-ao2@ao2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Ospite <ao2@ao2.it>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexander Gordeev <agordeev@redhat.com>
Cc: netdev@vger.kernel.org
---

The define is local to the file so the rename is safe.

Also, in the patch the indentation in the first hunk seems to be messed up,
but once you apply it, it is actually fine.

 drivers/net/ethernet/nvidia/forcedeth.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index fddb464..c6c379d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -406,7 +406,7 @@ union ring_type {
 
 #define NV_RX_DESCRIPTORVALID	(1<<16)
 #define NV_RX_MISSEDFRAME	(1<<17)
-#define NV_RX_SUBSTRACT1	(1<<18)
+#define NV_RX_SUBTRACT1		(1<<18)
 #define NV_RX_ERROR1		(1<<23)
 #define NV_RX_ERROR2		(1<<24)
 #define NV_RX_ERROR3		(1<<25)
@@ -423,7 +423,7 @@ union ring_type {
 #define NV_RX2_CHECKSUM_IP_TCP	(0x14000000)
 #define NV_RX2_CHECKSUM_IP_UDP	(0x18000000)
 #define NV_RX2_DESCRIPTORVALID	(1<<29)
-#define NV_RX2_SUBSTRACT1	(1<<25)
+#define NV_RX2_SUBTRACT1	(1<<25)
 #define NV_RX2_ERROR1		(1<<18)
 #define NV_RX2_ERROR2		(1<<19)
 #define NV_RX2_ERROR3		(1<<20)
@@ -2832,7 +2832,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX_ERROR_MASK) == NV_RX_FRAMINGERR) {
-						if (flags & NV_RX_SUBSTRACT1)
+						if (flags & NV_RX_SUBTRACT1)
 							len--;
 					}
 					/* the rest are hard errors */
@@ -2863,7 +2863,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
-						if (flags & NV_RX2_SUBSTRACT1)
+						if (flags & NV_RX2_SUBTRACT1)
 							len--;
 					}
 					/* the rest are hard errors */
@@ -2937,7 +2937,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				}
 				/* framing errors are soft errors */
 				else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
-					if (flags & NV_RX2_SUBSTRACT1)
+					if (flags & NV_RX2_SUBTRACT1)
 						len--;
 				}
 				/* the rest are hard errors */
-- 
2.0.0
