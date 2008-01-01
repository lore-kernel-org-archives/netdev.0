From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 14/26] atl1: move stray defines to header file
Date: Mon, 31 Dec 2007 20:22:41 -0600
Message-ID: <1199154173-4058-15-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:37907 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbYAACXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:23:07 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move some stray defines out to a header file.  Improve indentation from
ghastly to horrid.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   29 ++++++++++++-----------------
 drivers/net/atlx/atl1.h |    6 ++++++
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9c86ef4..f40cc6e 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -217,12 +217,6 @@ static s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
 	return ATLX_ERR_PHY;
 }
 
-#define CUSTOM_SPI_CS_SETUP	2
-#define CUSTOM_SPI_CLK_HI	2
-#define CUSTOM_SPI_CLK_LO	2
-#define CUSTOM_SPI_CS_HOLD	2
-#define CUSTOM_SPI_CS_HI	3
-
 static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
 {
 	int i;
@@ -232,17 +226,18 @@ static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
 	iowrite32(addr, hw->hw_addr + REG_SPI_ADDR);
 
 	value = SPI_FLASH_CTRL_WAIT_READY |
-	    (CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
-	    SPI_FLASH_CTRL_CS_SETUP_SHIFT | (CUSTOM_SPI_CLK_HI &
-					     SPI_FLASH_CTRL_CLK_HI_MASK) <<
-	    SPI_FLASH_CTRL_CLK_HI_SHIFT | (CUSTOM_SPI_CLK_LO &
-					   SPI_FLASH_CTRL_CLK_LO_MASK) <<
-	    SPI_FLASH_CTRL_CLK_LO_SHIFT | (CUSTOM_SPI_CS_HOLD &
-					   SPI_FLASH_CTRL_CS_HOLD_MASK) <<
-	    SPI_FLASH_CTRL_CS_HOLD_SHIFT | (CUSTOM_SPI_CS_HI &
-					    SPI_FLASH_CTRL_CS_HI_MASK) <<
-	    SPI_FLASH_CTRL_CS_HI_SHIFT | (1 & SPI_FLASH_CTRL_INS_MASK) <<
-	    SPI_FLASH_CTRL_INS_SHIFT;
+		(CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
+		SPI_FLASH_CTRL_CS_SETUP_SHIFT |
+		(CUSTOM_SPI_CLK_HI & SPI_FLASH_CTRL_CLK_HI_MASK) <<
+		SPI_FLASH_CTRL_CLK_HI_SHIFT |
+		(CUSTOM_SPI_CLK_LO & SPI_FLASH_CTRL_CLK_LO_MASK) <<
+		SPI_FLASH_CTRL_CLK_LO_SHIFT |
+		(CUSTOM_SPI_CS_HOLD & SPI_FLASH_CTRL_CS_HOLD_MASK) <<
+		SPI_FLASH_CTRL_CS_HOLD_SHIFT |
+		(CUSTOM_SPI_CS_HI & SPI_FLASH_CTRL_CS_HI_MASK) <<
+		SPI_FLASH_CTRL_CS_HI_SHIFT |
+		(1 & SPI_FLASH_CTRL_INS_MASK) <<
+		SPI_FLASH_CTRL_INS_SHIFT;
 
 	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
 
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 8198f82..3db9a34 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -335,6 +335,12 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 
 #define ATL1_EEDUMP_LEN				48
 
+#define CUSTOM_SPI_CS_SETUP	2
+#define CUSTOM_SPI_CLK_HI	2
+#define CUSTOM_SPI_CLK_LO	2
+#define CUSTOM_SPI_CS_HOLD	2
+#define CUSTOM_SPI_CS_HI	3
+
 /* Statistics counters collected by the MAC */
 struct stats_msg_block {
 	/* rx */
-- 
1.5.3.3

