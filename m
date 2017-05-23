From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 2/6] net/mlx5: Update the list of the PCI supported devices
Date: Tue, 23 May 2017 14:44:00 +0300
Message-ID: <20170523114404.20387-3-saeedm@mellanox.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Ilan Tayari <ilant@mellanox.com>,
        Noa Osherovich <noaos@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51084 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1762584AbdEWLoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 07:44:15 -0400
In-Reply-To: <20170523114404.20387-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

Add the BlueField device and VF IDs to the supported devices list.

Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0c123d571b4c..f933922d5cca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1520,6 +1520,8 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x101a), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 Ex VF */
 	{ PCI_VDEVICE(MELLANOX, 0x101b) },			/* ConnectX-6 */
 	{ PCI_VDEVICE(MELLANOX, 0x101c), MLX5_PCI_DEV_IS_VF},	/* ConnectX-6 VF */
+	{ PCI_VDEVICE(MELLANOX, 0xa2d2) },			/* BlueField integrated ConnectX-5 network controller */
+	{ PCI_VDEVICE(MELLANOX, 0xa2d3), MLX5_PCI_DEV_IS_VF},	/* BlueField integrated ConnectX-5 network controller VF */
 	{ 0, }
 };
 
-- 
2.11.0
