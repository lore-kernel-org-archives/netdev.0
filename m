From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH 1/2] PHY: fix typo in bcm63xx PHY driver table
Date: Fri, 9 Apr 2010 13:04:45 +0200
Message-ID: <201004091304.45392.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34059 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab0DILON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Apr 2010 07:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
---
diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index ac5e498..c128156 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -137,4 +137,4 @@ static struct mdio_device_id bcm63xx_tbl[] = {
 	{ }
 };
 
-MODULE_DEVICE_TABLE(mdio, bcm64xx_tbl);
+MODULE_DEVICE_TABLE(mdio, bcm63xx_tbl);
