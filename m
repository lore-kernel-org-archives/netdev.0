From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 01/14] phy: add sgmii and 10gkr modes to the phy_mode enum
Date: Fri, 25 Aug 2017 16:48:08 +0200
Message-ID: <20170825144821.31129-2-antoine.tenart@free-electrons.com>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds more generic PHY modes to the phy_mode enum, to
allow configuring generic PHYs to the SGMII and/or the 10GKR mode
by using the set_mode callback.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 include/linux/phy/phy.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
index 78bb0d7f6b11..e694d4008c4a 100644
--- a/include/linux/phy/phy.h
+++ b/include/linux/phy/phy.h
@@ -27,6 +27,8 @@ enum phy_mode {
 	PHY_MODE_USB_HOST,
 	PHY_MODE_USB_DEVICE,
 	PHY_MODE_USB_OTG,
+	PHY_MODE_SGMII,
+	PHY_MODE_10GKR,
 };
 
 /**
-- 
2.13.5
