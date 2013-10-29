From: Laurent Navet <laurent.navet@gmail.com>
Subject: [PATCH 1/2] octeon_mgmt: remove double validation of mac address
Date: Tue, 29 Oct 2013 22:27:33 +0100
Message-ID: <1383082053-12405-1-git-send-email-laurent.navet@gmail.com>
Cc: jiri@resnulli.us, david.daney@cavium.com, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Laurent Navet <laurent.navet@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mac address validity is already checked in of_get_mac_address().
No need to do it twice.

Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
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
1.8.4.rc3
