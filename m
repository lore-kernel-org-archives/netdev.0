From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 12/17] sky2: chip id enum
Date: Tue, 08 May 2007 20:50:01 -0700
Message-ID: <20070509035030.277026705@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:49693 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033240AbXEIEEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:00 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-chip-id-enum
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the chip id value's an enum. This makes it possible for GCC to do
better type checking for us.

Signed-off-by: Stephen Hemmminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.h |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-05-08 15:55:20.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-05-08 15:56:07.000000000 -0700
@@ -332,24 +332,27 @@ enum {
 };
 
 /*	B2_CHIP_ID		 8 bit 	Chip Identification Number */
-enum {
+enum sky2_chip_id {
 	CHIP_ID_YUKON_XL   = 0xb3, /* Chip ID for YUKON-2 XL */
 	CHIP_ID_YUKON_EC_U = 0xb4, /* Chip ID for YUKON-2 EC Ultra */
 	CHIP_ID_YUKON_EX   = 0xb5, /* Chip ID for YUKON-2 Extreme */
 	CHIP_ID_YUKON_EC   = 0xb6, /* Chip ID for YUKON-2 EC */
  	CHIP_ID_YUKON_FE   = 0xb7, /* Chip ID for YUKON-2 FE */
+};
 
+enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
 	CHIP_REV_YU_EC_A2    = 1,  /* Chip Rev. for Yukon-EC A2 */
 	CHIP_REV_YU_EC_A3    = 2,  /* Chip Rev. for Yukon-EC A3 */
-
+};
+enum yukon_ec_u_rev {
 	CHIP_REV_YU_EC_U_A0  = 1,
 	CHIP_REV_YU_EC_U_A1  = 2,
 	CHIP_REV_YU_EC_U_B0  = 3,
-
+};
+enum yukon_fe_rev {
 	CHIP_REV_YU_FE_A1    = 1,
 	CHIP_REV_YU_FE_A2    = 2,
-
 };
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */
@@ -1753,7 +1756,7 @@ struct sky2_hw {
 	struct pci_dev	     *pdev;
 	struct net_device    *dev[2];
 
-	u8	     	     chip_id;
+	enum sky2_chip_id    chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;
 	u8		     ports;

--

