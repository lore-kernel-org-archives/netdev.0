From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: e1000e: Use is_multicast_ether_addr helper
Date: Mon,  4 Jul 2011 11:47:04 +0200
Message-ID: <1309772824-22157-1-git-send-email-tklauser@distanz.ch>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:42400 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762Ab1GDJrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:47:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/e1000e/lib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index dd8ab05..b85b3ca 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -220,7 +220,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	}
 
 	/* if multicast bit is set, the alternate address will not be used */
-	if (alt_mac_addr[0] & 0x01) {
+	if (is_multicast_ether_addr(alt_mac_addr)) {
 		e_dbg("Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
-- 
1.7.5.4

