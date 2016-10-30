From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 05/15] net/mlx5: Add ConnectX-5 PCIe 4.0 VF device ID
Date: Sun, 30 Oct 2016 23:21:58 +0200
Message-ID: <1477862528-4328-6-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60239 "EHLO mellanox.co.il"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756675AbcJ3VXn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Oct 2016 17:23:43 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the mlx5 driver to support ConnectX-5 PCIe 4.0 VFs, we add the
device ID "0x101a" to mlx5_core_pci_table.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index d9c3c70..197e04c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1422,6 +1422,7 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5, PCIe 3.0 */
 	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x1019) },			/* ConnectX-5, PCIe 4.0 */
+	{ PCI_VDEVICE(MELLANOX, 0x101a), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5, PCIe 4.0 VF */
 	{ 0, }
 };
 
-- 
2.7.4
