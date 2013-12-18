From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/9] net: phy: icplus: fix checkpath error
Date: Tue, 17 Dec 2013 21:38:08 -0800
Message-ID: <1387345093-14168-5-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:48300 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3LRFi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:28 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so7713753oag.14
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:27 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/icplus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index b5ddd50..97bf58b 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -48,7 +48,7 @@ MODULE_LICENSE("GPL");
 static int ip175c_config_init(struct phy_device *phydev)
 {
 	int err, i;
-	static int full_reset_performed = 0;
+	static int full_reset_performed;
 
 	if (full_reset_performed == 0) {
 
-- 
1.8.3.2
