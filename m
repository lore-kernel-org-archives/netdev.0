From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: igb: Use is_multicast_ether_addr helper
Date: Mon,  4 Jul 2011 11:50:15 +0200
Message-ID: <1309773015-23598-1-git-send-email-tklauser@distanz.ch>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:42638 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762Ab1GDJuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:50:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/igb/e1000_mac.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index ce8255f..c822904 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -29,6 +29,7 @@
 #include <linux/delay.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 
 #include "e1000_mac.h"
 
@@ -217,7 +218,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	}
 
 	/* if multicast bit is set, the alternate address will not be used */
-	if (alt_mac_addr[0] & 0x01) {
+	if (is_multicast_ether_addr(alt_mac_addr)) {
 		hw_dbg("Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
-- 
1.7.5.4

