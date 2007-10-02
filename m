From: akpm@linux-foundation.org
Subject: [patch 12/13] Clean up redundant PHY write line for ULi526x Ethernet driver
Date: Tue, 02 Oct 2007 14:11:43 -0700
Message-ID: <200710022111.l92LBhBB022510@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	tie-fei.zang@freescale.com, grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35894 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755249AbXJBVV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:21:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roy Zang <tie-fei.zang@freescale.com>

Clean up redundant PHY write line for ULi526x Ethernet Driver.

Signed-off-by: Roy Zang <tie-fei.zang@freescale.com>
Cc: Jeff Garzik <jeff@garzik.org>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/uli526x.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN drivers/net/tulip/uli526x.c~clean-up-redundant-phy-write-line-for-uli526x-ethernet drivers/net/tulip/uli526x.c
--- a/drivers/net/tulip/uli526x.c~clean-up-redundant-phy-write-line-for-uli526x-ethernet
+++ a/drivers/net/tulip/uli526x.c
@@ -1599,7 +1599,6 @@ static void uli526x_process_mode(struct 
 			case ULI526X_100MFD: phy_reg = 0x2100; break;
 			}
 			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
-       			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
 		}
 	}
 }
_
