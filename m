From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCH net-next 7/9] net/mlx5_core: Add more supported devices
Date: Tue,  2 Dec 2014 12:26:17 +0200
Message-ID: <1417515979-22418-8-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417515979-22418-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add ConnectX-4LX to the list of supported devices as well as their virtual
functions.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c9d4a024f186..3f4525619a07 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -903,8 +903,12 @@ static void remove_one(struct pci_dev *pdev)
 }
 
 static const struct pci_device_id mlx5_core_pci_table[] = {
-	{ PCI_VDEVICE(MELLANOX, 4113) }, /* MT4113 Connect-IB */
+	{ PCI_VDEVICE(MELLANOX, 4113) }, /* Connect-IB */
+	{ PCI_VDEVICE(MELLANOX, 4114) }, /* Connect-IB VF */
 	{ PCI_VDEVICE(MELLANOX, 4115) }, /* ConnectX-4 */
+	{ PCI_VDEVICE(MELLANOX, 4116) }, /* ConnectX-4 VF */
+	{ PCI_VDEVICE(MELLANOX, 4117) }, /* ConnectX-4LX */
+	{ PCI_VDEVICE(MELLANOX, 4118) }, /* ConnectX-4LX VF */
 	{ 0, }
 };
 
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
