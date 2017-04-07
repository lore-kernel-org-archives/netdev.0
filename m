From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/7] net/mlx5: Update the list of the PCI supported devices
Date: Fri,  7 Apr 2017 21:26:50 +0300
Message-ID: <20170407182656.6734-2-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47248 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756050AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Rename the ConnectX-5 PCIe 4.0 to be ConnectX-5 Ex.
Also add the upcoming ConnectX-6 and it's VF IDs to the list.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 60154a175bd3..9c2bec732af9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1514,8 +1514,10 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1016), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4LX VF */
 	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5, PCIe 3.0 */
 	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
-	{ PCI_VDEVICE(MELLANOX, 0x1019) },			/* ConnectX-5, PCIe 4.0 */
-	{ PCI_VDEVICE(MELLANOX, 0x101a), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5, PCIe 4.0 VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1019) },			/* ConnectX-5 Ex */
+	{ PCI_VDEVICE(MELLANOX, 0x101a), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 Ex VF */
+	{ PCI_VDEVICE(MELLANOX, 0x101b) },			/* ConnectX-6 */
+	{ PCI_VDEVICE(MELLANOX, 0x101c), MLX5_PCI_DEV_IS_VF},	/* ConnectX-6 VF */
 	{ 0, }
 };
 
-- 
2.11.0
