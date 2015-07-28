From: mohun106@gmail.com
Subject: [PATCH 3/3] net: thunderx: Select CONFIG_MDIO_OCTEON for ThunderX NIC
Date: Mon, 27 Jul 2015 19:14:43 -0700
Message-ID: <1438049683-10630-4-git-send-email-mohun106@gmail.com>
References: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>

The CONFIG_MDIO_OCTEON is required so that the ThunderX NIC driver can
talk to the PHY drivers.

Signed-off-by: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
---
 drivers/net/ethernet/cavium/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index c4d6bbe..3584420 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -37,6 +37,8 @@ config	THUNDER_NIC_BGX
 	tristate "Thunder MAC interface driver (BGX)"
 	depends on 64BIT
 	default ARCH_THUNDER
+	select PHYLIB
+	select MDIO_OCTEON
 	---help---
 	  This driver supports programming and controlling of MAC
 	  interface from NIC physical function driver.
-- 
1.7.1
