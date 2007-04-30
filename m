From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2/2] atl1: fix whitespace damage
Date: Sun, 29 Apr 2007 21:42:11 -0500
Message-ID: <11779009312624-git-send-email-jacliburn@bellsouth.net>
References: <11779009311121-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf07aec.mail.bellsouth.net ([205.152.59.55]:33213 "EHLO
	imf07aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422838AbXD3DOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 23:14:08 -0400
In-Reply-To: <11779009311121-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove trailing whitespace and spaces preceding tabs.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_hw.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 5b9dd3c..ef886bd 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -2,20 +2,20 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
@@ -42,9 +42,9 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	u32 icr;
 	int i;
 
-	/* 
+	/*
 	 * Clear Interrupt mask to stop board from generating
-	 * interrupts & Clear any pending interrupt events 
+	 * interrupts & Clear any pending interrupt events
 	 */
 	/*
 	 * iowrite32(0, hw->hw_addr + REG_IMR);
@@ -137,8 +137,8 @@ s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
 	int i;
 
 	val = ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIFT |
-	    	MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
- 		MDIO_CLK_SEL_SHIFT;
+		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
+		MDIO_CLK_SEL_SHIFT;
 	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
 	ioread32(hw->hw_addr + REG_MDIO_CTRL);
 
@@ -205,7 +205,7 @@ static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
 
 /*
  * get_permanent_address
- * return 0 if get valid mac address, 
+ * return 0 if get valid mac address,
  */
 static int atl1_get_permanent_address(struct atl1_hw *hw)
 {
@@ -302,7 +302,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 }
 
 /*
- * Reads the adapter's MAC address from the EEPROM 
+ * Reads the adapter's MAC address from the EEPROM
  * hw - Struct containing variables accessed by shared code
  */
 s32 atl1_read_mac_addr(struct atl1_hw *hw)
@@ -629,7 +629,7 @@ static void atl1_init_flash_opcode(struct atl1_hw *hw)
  * Performs basic configuration of the adapter.
  * hw - Struct containing variables accessed by shared code
  * Assumes that the controller has previously been reset and is in a
- * post-reset uninitialized state. Initializes multicast table, 
+ * post-reset uninitialized state. Initializes multicast table,
  * and  Calls routines to setup link
  * Leaves the transmit and receive units disabled and uninitialized.
  */
-- 
1.5.0.6

