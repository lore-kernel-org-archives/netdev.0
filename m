From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 2/3] net: cavium: For Kconfig THUNDER_NIC_BGX, select MDIO_THUNDER.
Date: Mon, 14 Mar 2016 17:30:38 -0700
Message-ID: <1458001839-15993-3-git-send-email-ddaney.cavm@gmail.com>
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

Previously we selected MDIO_OCTEON, which after creating the Thunder
specific MDIO bus driver is much less useful.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 8fb84e6..953aa40 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -35,7 +35,7 @@ config	THUNDER_NIC_BGX
 	tristate "Thunder MAC interface driver (BGX)"
 	depends on 64BIT
 	select PHYLIB
-	select MDIO_OCTEON
+	select MDIO_THUNDER
 	---help---
 	  This driver supports programming and controlling of MAC
 	  interface from NIC physical function driver.
-- 
1.7.11.7
