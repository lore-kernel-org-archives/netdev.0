From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/4] net: phy: broadcom: add new Broadcom OUI
Date: Tue, 26 Aug 2014 13:15:26 -0700
Message-ID: <1409084127-30387-4-git-send-email-f.fainelli@gmail.com>
References: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52044 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbaHZUQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:16:04 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so24282187pac.17
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 13:16:04 -0700 (PDT)
In-Reply-To: <1409084127-30387-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom started to use a new OUI for its 2013 and newer products:
D4-01-29 which translates into 0xae025000 for a 32-bits OUI, add its
definition.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 921f17ca4c26..cbcfad36d4c0 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -23,7 +23,7 @@
 #define PHY_BCM_OUI_3			0x03625c00
 #define PHY_BCM_OUI_4			0x600d8400
 #define PHY_BCM_OUI_5			0x03625e00
-
+#define PHY_BCM_OUI_6			0xae025000
 
 #define PHY_BCM_FLAGS_MODE_COPPER	0x00000001
 #define PHY_BCM_FLAGS_MODE_1000BX	0x00000002
-- 
1.9.1
