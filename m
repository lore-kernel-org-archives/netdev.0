From: <shh.xie@gmail.com>
Subject: [PATCH 2/6] [v4] phylib: introduce PHY_INTERFACE_MODE_XGMII for 10G PHY
Date: Tue, 7 Jan 2014 10:13:37 +0800
Message-ID: <1389060817-7002-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@gmail.com>

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
resend for v4.

 drivers/of/of_net.c | 1 +
 include/linux/phy.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index 8f9be2e..a208a45 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -30,6 +30,7 @@ static const char *phy_modes[] = {
 	[PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
 	[PHY_INTERFACE_MODE_RTBI]	= "rtbi",
 	[PHY_INTERFACE_MODE_SMII]	= "smii",
+	[PHY_INTERFACE_MODE_XGMII]	= "xgmii",
 };
 
 /**
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 0ff2476..1d6d1b9 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -66,6 +66,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
+	PHY_INTERFACE_MODE_XGMII,
 } phy_interface_t;
 
 
-- 
1.8.4.1
