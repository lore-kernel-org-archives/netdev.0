From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: phy: broadcom: fix PHY_BCM_OUI_4
Date: Tue, 26 Aug 2014 13:15:25 -0700
Message-ID: <1409084127-30387-3-git-send-email-f.fainelli@gmail.com>
References: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:39788 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbaHZUQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:16:03 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so23204641pdj.12
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 13:16:03 -0700 (PDT)
In-Reply-To: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY_BCM_OUI_4 is missing two significant digits that actually make it an
OUI, add those missing bits so it becomes usable again for matching.

Fixes: b560a58c45c6 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index ee1431d976fa..921f17ca4c26 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -21,7 +21,7 @@
 #define PHY_BCM_OUI_1			0x00206000
 #define PHY_BCM_OUI_2			0x0143bc00
 #define PHY_BCM_OUI_3			0x03625c00
-#define PHY_BCM_OUI_4			0x600d0000
+#define PHY_BCM_OUI_4			0x600d8400
 #define PHY_BCM_OUI_5			0x03625e00
 
 
-- 
1.9.1
