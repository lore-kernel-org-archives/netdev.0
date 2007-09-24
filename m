From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: [PATCH] Clean up redundant PHY write line for ULi526x Ethernet
	driver
Date: 24 Sep 2007 16:57:42 +0800
Message-ID: <1190624262.20089.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:49038 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbXIXI4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 04:56:42 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l8O8ucSm017637
	for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 01:56:39 -0700 (MST)
Received: from zch01exm23.fsl.freescale.net (zch01exm23.ap.freescale.net [10.192.129.207])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l8O8uZLX027562
	for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 03:56:36 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roy Zang <tie-fei.zang@freescale.com>

Clean up redundant PHY write line for ULi526x Ethernet
Driver.

Signed-off-by: Roy Zang <tie-fei.zang@freescale.com>
---
 drivers/net/tulip/uli526x.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index ca2548e..53a8e65 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1512,7 +1512,6 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 			case ULI526X_100MFD: phy_reg = 0x2100; break;
 			}
 			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
-       			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
 		}
 	}
 }
-- 
1.5.2




