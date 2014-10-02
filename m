From: Eli Cohen <eli@mellanox.com>
Subject: [PATCH V2 net-next 5/5] net/mlx5_core: Add ConnectX-4 to list of supported devices
Date: Thu,  2 Oct 2014 12:19:46 +0300
Message-ID: <1412241586-10108-6-git-send-email-eli@mellanox.com>
References: <1412241586-10108-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54710 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751066AbaJBJT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 05:19:58 -0400
In-Reply-To: <1412241586-10108-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the upcoming ConnectX-4 device to the list of supported devices by then
mlx5 driver.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index b9e3259e415f..3d8e8e489b2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -897,6 +897,7 @@ static void remove_one(struct pci_dev *pdev)
 
 static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 4113) }, /* MT4113 Connect-IB */
+	{ PCI_VDEVICE(MELLANOX, 4115) }, /* ConnectX-4 */
 	{ 0, }
 };
 
-- 
2.1.1
