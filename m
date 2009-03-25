From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] r6040: Fix second PHY address
Date: Wed, 25 Mar 2009 10:34:35 +0100
Message-ID: <200903251034.36795.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f208.google.com ([209.85.217.208]:39012 "EHLO
	mail-gx0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbZCYJeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 05:34:44 -0400
Received: by gxk4 with SMTP id 4so7390861gxk.13
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 02:34:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the second PHY address which is strapped
to be at PHY address 3 instead of 2.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 9c95ebe..d3458ef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -54,7 +54,7 @@
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
-#define PHY2_ADDR	2	/* For MAC2 */
+#define PHY2_ADDR	3	/* For MAC2 */
 #define PHY_MODE	0x3100	/* PHY CHIP Register 0 */
 #define PHY_CAP		0x01E1	/* PHY CHIP Register 4 */
 
