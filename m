From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 01/12] net: phy: bcm-phylib: replace obsolete EEE macro references
Date: Mon, 13 Mar 2017 17:41:31 -0700
Message-ID: <20170314004142.4746-2-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macros MDIO_AN_EEE_ADV_100TX and MDIO_AN_EEE_ADV_1000T are now
considered obsolete and are replaced in the kernel with the generic
macros MDIO_EEE_100TX and MDIO_EEE_1000T respectively.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/phy/bcm-phy-lib.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index ab9ad689617c..9656dbeb5de5 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Broadcom Corporation
+ * Copyright (C) 2015-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -221,9 +221,9 @@ int bcm_phy_set_eee(struct phy_device *phydev, bool enable)
 		return val;
 
 	if (enable)
-		val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+		val |= (MDIO_EEE_100TX | MDIO_EEE_1000T);
 	else
-		val &= ~(MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+		val &= ~(MDIO_EEE_100TX | MDIO_EEE_1000T);
 
 	phy_write_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
 			       MDIO_MMD_AN, (u32)val);
-- 
2.11.1
