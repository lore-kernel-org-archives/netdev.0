From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH 1/1] net: phy: bcm-phy-lib: Fix module license issue
Date: Tue, 13 Oct 2015 13:40:12 -0700
Message-ID: <1444768812-31476-2-git-send-email-arunp@broadcom.com>
References: <1444768812-31476-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:57961 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbbJMUkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 16:40:20 -0400
In-Reply-To: <1444768812-31476-1-git-send-email-arunp@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'bcm-phy-lib.c', added as a part of the commit
"net: phy: Add Broadcom phy library for common interfaces"
was missing the module license. This was causing an issue
when the library is built as a module; "module license
'unspecified' taints kernel".

This patch fixes the issue by adding the module license,
author and description to the bcm-phy-lib.c file.

Fixes: a1cba5613edf5 ("net: phy: Add Broadcom phy library for common
interfaces")
Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
---
 drivers/net/phy/bcm-phy-lib.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index 13e161e..ddb377e 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -15,6 +15,7 @@
 #include <linux/brcmphy.h>
 #include <linux/export.h>
 #include <linux/mdio.h>
+#include <linux/module.h>
 #include <linux/phy.h>
 
 #define MII_BCM_CHANNEL_WIDTH     0x2000
@@ -207,3 +208,6 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
 }
 EXPORT_SYMBOL_GPL(bcm_phy_enable_eee);
 
+MODULE_DESCRIPTION("Broadcom PHY Library");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Broadcom Corporation");
-- 
2.6.1
