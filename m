From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/3] phy: mdio-cavium: Add missing MODULE_* annotations.
Date: Mon, 14 Mar 2016 17:30:37 -0700
Message-ID: <1458001839-15993-2-git-send-email-ddaney.cavm@gmail.com>
References: <1458001839-15993-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458001839-15993-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

When the code was factored out of mdio-octeon.c, the
MODULE_DESCRIPTION, MODULE_AUTHOR and MODULE_LICENSE annotations were
inadvertently omitted.  Restore them so that we don't get kernel taint
warnings upon module loading.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/mdio-cavium.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/mdio-cavium.c b/drivers/net/phy/mdio-cavium.c
index e796ee1..6df2fa7 100644
--- a/drivers/net/phy/mdio-cavium.c
+++ b/drivers/net/phy/mdio-cavium.c
@@ -147,3 +147,7 @@ int cavium_mdiobus_write(struct mii_bus *bus, int phy_id, int regnum, u16 val)
 	return 0;
 }
 EXPORT_SYMBOL(cavium_mdiobus_write);
+
+MODULE_DESCRIPTION("Common code for OCTEON and Thunder MDIO bus drivers");
+MODULE_AUTHOR("David Daney");
+MODULE_LICENSE("GPL");
-- 
1.7.11.7
