From: Myron Stowe <myron.stowe@redhat.com>
Subject: [PATCH 2/2] net/mlx5e: Use device ID defines
Date: Wed, 24 May 2017 16:47:52 -0600
Message-ID: <20170524224752.24221.41019.stgit@amt.stowe>
References: <20170524224734.24221.33787.stgit@amt.stowe>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, saeedm@mellanox.com, noaos@mellanox.com,
        tariqt@mellanox.com
To: linux-pci@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170524224734.24221.33787.stgit@amt.stowe>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use Mellanox device ID definitions in the mlx5 ID table so tools such as
'grep' and 'cscope' can be used to help find related aspects.

No functional change intended.

Signed-off-by: Myron Stowe <myron.stowe@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0c123d5..98642eb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1508,17 +1508,17 @@ static void shutdown(struct pci_dev *pdev)
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
-	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5, PCIe 3.0 */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX5) },
 	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
-	{ PCI_VDEVICE(MELLANOX, 0x1019) },			/* ConnectX-5 Ex */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX5_EX) },
 	{ PCI_VDEVICE(MELLANOX, 0x101a), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 Ex VF */
-	{ PCI_VDEVICE(MELLANOX, 0x101b) },			/* ConnectX-6 */
+	{ PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_CONNECTX6) },
 	{ PCI_VDEVICE(MELLANOX, 0x101c), MLX5_PCI_DEV_IS_VF},	/* ConnectX-6 VF */
 	{ 0, }
 };
