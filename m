From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH] macb: convert platform data phy_irq_pin to an int
Date: Thu, 24 Nov 2011 09:48:18 +0000
Message-ID: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
Cc: Jamie Iles <jamie@jamieiles.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38389 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131Ab1KXJsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 04:48:25 -0500
Received: by yenl6 with SMTP id l6so7646yen.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 01:48:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AT91 platforms have been updated to set the phy_irq_pin to -EINVAL if
not present, but phy_irq_pin is currently a u8.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 include/linux/platform_data/macb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
index e7c748f..b081c72 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -10,7 +10,7 @@
 
 struct macb_platform_data {
 	u32		phy_mask;
-	u8		phy_irq_pin;	/* PHY IRQ */
+	int		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
 };
 
-- 
1.7.4.1
