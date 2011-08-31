From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH] mii: Remove references to DP83840 PHY in mii.h
Date: Wed, 31 Aug 2011 16:35:28 +0100
Message-ID: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
Cc: davem@davemloft.net, Mark Einon <mark.einon@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38233 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab1HaPgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 11:36:47 -0400
Received: by wyh22 with SMTP id 22so244587wyh.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 08:36:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are references to this PHY chip in the generic mii.h header, so removing them.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 include/linux/mii.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index 103113a..4c3cfb5 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -40,12 +40,12 @@
 #define BMCR_CTST               0x0080  /* Collision test              */
 #define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
 #define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */
-#define BMCR_ISOLATE            0x0400  /* Disconnect DP83840 from MII */
-#define BMCR_PDOWN              0x0800  /* Powerdown the DP83840       */
+#define BMCR_ISOLATE            0x0400  /* Disconnect PHY from MII     */
+#define BMCR_PDOWN              0x0800  /* Powerdown                   */
 #define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
 #define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
 #define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */
-#define BMCR_RESET              0x8000  /* Reset the DP83840           */
+#define BMCR_RESET              0x8000  /* Reset                       */
 
 /* Basic mode status register. */
 #define BMSR_ERCAP              0x0001  /* Ext-reg capability          */
@@ -55,9 +55,9 @@
 #define BMSR_RFAULT             0x0010  /* Remote fault detected       */
 #define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
 #define BMSR_RESV               0x00c0  /* Unused...                   */
-#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
-#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX */
-#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX */
+#define BMSR_ESTATEN		0x0100	/* Extended Status in R15      */
+#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX       */
+#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX       */
 #define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
 #define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
 #define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
-- 
1.7.6
