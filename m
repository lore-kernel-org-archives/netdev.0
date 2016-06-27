From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/7] net/mlx5: Add ConnectX-5 PCIe 4.0 to list of supported devices
Date: Mon, 27 Jun 2016 12:08:33 +0300
Message-ID: <1467018518-11630-3-git-send-email-saeedm@mellanox.com>
References: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53193 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751215AbcF0JQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:16:10 -0400
In-Reply-To: <1467018518-11630-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add the upcoming ConnectX-5 PCIe 4.0 device to the list of
supported devices by the mlx5 driver.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index a19b593..c65f4a1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1508,8 +1508,9 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1014), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x1015) },			/* ConnectX-4LX */
 	{ PCI_VDEVICE(MELLANOX, 0x1016), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4LX VF */
-	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5 */
+	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5, PCIe 3.0 */
 	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1019) },			/* ConnectX-5, PCIe 4.0 */
 	{ 0, }
 };
 
-- 
2.8.0
