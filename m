From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] bgmac: Utilize BRCM_PSEUDO_PHY_ADDR
Date: Wed, 10 Jun 2015 18:08:00 -0700
Message-ID: <1433984881-28781-5-git-send-email-f.fainelli@gmail.com>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33896 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbbFKBJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:16 -0400
Received: by qkoo18 with SMTP id o18so33927294qko.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:16 -0700 (PDT)
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What BGMAC defines as BGMAC_PHY_NOREGS is in fact the Broadcom Ethernet
switches' pseudo-PHY address (30), utilize the newly introduced constant
from brcmphy.h

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index db27febbb215..4fbb093e0d84 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -13,6 +13,7 @@
 	dev_dbg(&(bgmac)->core->dev, fmt, ##__VA_ARGS__)
 
 #include <linux/bcma/bcma.h>
+#include <linux/brcmphy.h>
 #include <linux/netdevice.h>
 
 #define BGMAC_DEV_CTL				0x000
@@ -349,7 +350,7 @@
 #define BGMAC_DESC_CTL0_SOF			0x80000000	/* Start of frame */
 #define BGMAC_DESC_CTL1_LEN			0x00001FFF
 
-#define BGMAC_PHY_NOREGS			0x1E
+#define BGMAC_PHY_NOREGS			BRCM_PSEUDO_PHY_ADDR
 #define BGMAC_PHY_MASK				0x1F
 
 #define BGMAC_MAX_TX_RINGS			4
-- 
2.1.0
