From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/5] net: mdio-mux: printing driver version is useless
Date: Wed, 30 Aug 2017 19:46:49 +0200
Message-ID: <20170830174651.30325-4-clabbe.montjoie@gmail.com>
References: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37933 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdH3RtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:49:03 -0400
In-Reply-To: <20170830174651.30325-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the driver version information because this information
is not useful in an upstream kernel driver.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/phy/mdio-mux.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 5e08e89465c5..9a889a529b9c 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -179,7 +179,6 @@ int mdio_mux_init(struct device *dev,
 	}
 	if (pb->children) {
 		*mux_handle = pb;
-		dev_info(dev, "Version " DRV_VERSION "\n");
 		return 0;
 	}
 
-- 
2.13.5
