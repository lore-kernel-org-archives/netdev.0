From: Myron Stowe <myron.stowe@redhat.com>
Subject: [PATCH v2] net/mlx5e: Use device ID defines
Date: Tue, 20 Jun 2017 11:21:26 -0600
Message-ID: <20170620172126.784.3849.stgit@amt.stowe>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: noaos@mellanox.com, saeedm@mellanox.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, tariqt@mellanox.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use Mellanox device ID definitions in the driver's mlx5 ID table so tools
such as 'grep' and 'cscope' can be used to help find correlated material
(such as INTx Masking quirks: d76d2fe05fd PCI: Convert Mellanox broken
INTx quirks to be for listed devices only).

No functional change intended.

Signed-off-by: Myron Stowe <myron.stowe@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0c123d5..8a4e292 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1508,11 +1508,11 @@ static void shutdown(struct pci_dev *pdev)
 }
 
 static const struct pci_device_id mlx5_core_pci_table[] = {
-	{ PCI_VDEVICE(MELLANOX, 0x1011) },			/* Connect-IB */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTIB) },
 	{ PCI_VDEVICE(MELLANOX, 0x1012), MLX5_PCI_DEV_IS_VF},	/* Connect-IB VF */
-	{ PCI_VDEVICE(MELLANOX, 0x1013) },			/* ConnectX-4 */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX4) },
 	{ PCI_VDEVICE(MELLANOX, 0x1014), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4 VF */
-	{ PCI_VDEVICE(MELLANOX, 0x1015) },			/* ConnectX-4LX */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX4_LX) },
 	{ PCI_VDEVICE(MELLANOX, 0x1016), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4LX VF */
 	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5, PCIe 3.0 */
 	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
