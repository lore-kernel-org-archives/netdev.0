From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: phy: broadcom: include phy.h for brcmphy.h
Date: Wed, 10 Jun 2015 18:07:57 -0700
Message-ID: <1433984881-28781-2-git-send-email-f.fainelli@gmail.com>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, hauke@hauke-m.de,
	zajec5@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35727 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbFKBJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 21:09:12 -0400
Received: by qkhq76 with SMTP id q76so33596722qkh.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 18:09:11 -0700 (PDT)
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We utilize inline functions from the PHY library, make sure that we do
include phy.h in brcmphy.h in order for the code including brcmphy.h not
to have to resolve this inclusion dependency.

Fixes: 705314797b8b ("net: phy: broadcom: move shadow 0x1C register accessors to brcmphy.h")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/brcmphy.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 656da2a12ffe..abb6106f839d 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_BRCMPHY_H
 #define _LINUX_BRCMPHY_H
 
+#include <linux/phy.h>
+
 #define PHY_ID_BCM50610			0x0143bd60
 #define PHY_ID_BCM50610M		0x0143bd70
 #define PHY_ID_BCM5241			0x0143bc30
-- 
2.1.0
