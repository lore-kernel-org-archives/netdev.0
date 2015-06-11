From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: phy: broadcom: define Broadcom pseudo-PHY address in brcmphy.h
Date: Wed, 10 Jun 2015 18:07:58 -0700
Message-ID: <1433984881-28781-3-git-send-email-f.fainelli@gmail.com>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36238 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbFKBJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:13 -0400
Received: by qgep100 with SMTP id p100so21702495qge.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:13 -0700 (PDT)
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the pseudo-PHY address (30) which is used by all Broadcom
Ethernet switches in a shared header file.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index abb6106f839d..697ca7795bd9 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -3,6 +3,11 @@
 
 #include <linux/phy.h>
 
+/* All Broadcom Ethernet switches have a pseudo-PHY at address 30 which is used
+ * to configure the switch internal registers via MDIO accesses.
+ */
+#define BRCM_PSEUDO_PHY_ADDR           30
+
 #define PHY_ID_BCM50610			0x0143bd60
 #define PHY_ID_BCM50610M		0x0143bd70
 #define PHY_ID_BCM5241			0x0143bc30
-- 
2.1.0
