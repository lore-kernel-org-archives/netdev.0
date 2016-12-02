From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: [PATCH v2] net: phy: dp83848: Support ethernet pause frames
Date: Fri, 2 Dec 2016 15:57:49 +0100
Message-ID: <20161202145748.GA19016@axis.com>
References: <20161202142203.GY19016@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Quadros <rogerq@ti.com>, "Andrew F. Davis" <afd@ti.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161202142203.GY19016@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the documentation, the PHYs supported by this driver
can also support pause frames. Announce this to be so.
Tested with a TI83822I.

Acked-by: Andrew F. Davis <afd@ti.com>
Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>
---
 drivers/net/phy/dp83848.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 800b39f..320d0dc 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -88,7 +88,9 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 		.phy_id		= _id,				\
 		.phy_id_mask	= 0xfffffff0,			\
 		.name		= _name,			\
-		.features	= PHY_BASIC_FEATURES,		\
+		.features	= (PHY_BASIC_FEATURES |		\
+				   SUPPORTED_Pause |		\
+				   SUPPORTED_Asym_Pause),	\
 		.flags		= PHY_HAS_INTERRUPT,		\
 								\
 		.soft_reset	= genphy_soft_reset,		\
-- 
2.1.4


/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
