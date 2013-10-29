From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH] netdev: octeon_mgmt: drop redundant mac address check
Date: Tue, 29 Oct 2013 02:27:41 +0100
Message-ID: <1383010061-25461-1-git-send-email-luka@openwrt.org>
Cc: david.daney@cavium.com, Luka Perkov <luka@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:35766 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034Ab3J2B1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 21:27:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address().

Signed-off-by: Luka Perkov <luka@openwrt.org>
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
1.8.4.1
