From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 2/2] mii: Remove references to DP83840 PHY in mii.h
Date: Thu,  1 Sep 2011 10:22:17 +0100
Message-ID: <1314868937-2536-2-git-send-email-mark.einon@gmail.com>
References: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
 <1314868937-2536-1-git-send-email-mark.einon@gmail.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Mark Einon <mark.einon@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52401 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab1IAJXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 05:23:34 -0400
Received: by wwf5 with SMTP id 5so1689773wwf.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 02:23:33 -0700 (PDT)
In-Reply-To: <1314868937-2536-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are references to this PHY chip in the generic mii.h header, so removing them.
Re-jiggle the changed comments, in response to points raised by Ben Hutchings.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 include/linux/mii.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index d9f7750..2774823 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -39,12 +39,12 @@
 #define BMCR_CTST		0x0080	/* Collision test              */
 #define BMCR_FULLDPLX		0x0100	/* Full duplex                 */
 #define BMCR_ANRESTART		0x0200	/* Auto negotiation restart    */
-#define BMCR_ISOLATE		0x0400	/* Disconnect DP83840 from MII */
-#define BMCR_PDOWN		0x0800	/* Powerdown the DP83840       */
+#define BMCR_ISOLATE		0x0400	/* Isolate data paths from MII */
+#define BMCR_PDOWN		0x0800	/* Enable low power state      */
 #define BMCR_ANENABLE		0x1000	/* Enable auto negotiation     */
 #define BMCR_SPEED100		0x2000	/* Select 100Mbps              */
 #define BMCR_LOOPBACK		0x4000	/* TXD loopback bits           */
-#define BMCR_RESET		0x8000	/* Reset the DP83840           */
+#define BMCR_RESET		0x8000	/* Reset to default state      */
 
 /* Basic mode status register. */
 #define BMSR_ERCAP		0x0001	/* Ext-reg capability          */
-- 
1.7.6
