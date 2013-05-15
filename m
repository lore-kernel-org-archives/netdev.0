From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH] broadcom: add include guards to include/linux/brcmphy.h
Date: Wed, 15 May 2013 18:00:25 +0000
Message-ID: <1368640825-22382-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cernekee@gmail.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4588 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759802Ab3EOSBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 14:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/linux/brcmphy.h is currently not protected against double
inclusion, add ifdefs guard to fix that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index b840a49..677b4f0 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -1,3 +1,6 @@
+#ifndef _LINUX_BRCMPHY_H
+#define _LINUX_BRCMPHY_H
+
 #define PHY_ID_BCM50610			0x0143bd60
 #define PHY_ID_BCM50610M		0x0143bd70
 #define PHY_ID_BCM5241			0x0143bc30
@@ -29,3 +32,5 @@
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
 #define PHY_BCM_FLAGS_VALID		0x80000000
+
+#endif /* _LINUX_BRCMPHY_H */
-- 
1.8.1.2
