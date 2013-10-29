From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH v2] octeon_mgmt: drop redundant mac address check
Date: Wed, 30 Oct 2013 00:09:12 +0100
Message-ID: <1383088152-24869-1-git-send-email-luka@openwrt.org>
Cc: Luka Perkov <luka@openwrt.org>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:33253 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab3J2XJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 19:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address().

Signed-off-by: Luka Perkov <luka@openwrt.org>
Acked-by: David Daney <david.daney@cavium.com>
CC: David Miller <davem@davemloft.net>
---
v1->v2:

 * cosmetic commit message fix based on comment from David Miller
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 622aa75..1b326cbc 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1545,7 +1545,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 
 	mac = of_get_mac_address(pdev->dev.of_node);
 
-	if (mac && is_valid_ether_addr(mac))
+	if (mac)
 		memcpy(netdev->dev_addr, mac, ETH_ALEN);
 	else
 		eth_hw_addr_random(netdev);
-- 
1.8.4.2
