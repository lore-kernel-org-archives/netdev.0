From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx5_core: Move to use hex PCI device IDs
Date: Tue,  3 Feb 2015 17:57:18 +0200
Message-ID: <1422979041-25208-5-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40286 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966308AbbBCP6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:19 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Align the IDs in the code with the modinfo, lspci -n, etc tools outputs.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3f45256..d665193 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -903,12 +903,12 @@ static void remove_one(struct pci_dev *pdev)
 }
 
 static const struct pci_device_id mlx5_core_pci_table[] = {
-	{ PCI_VDEVICE(MELLANOX, 4113) }, /* Connect-IB */
-	{ PCI_VDEVICE(MELLANOX, 4114) }, /* Connect-IB VF */
-	{ PCI_VDEVICE(MELLANOX, 4115) }, /* ConnectX-4 */
-	{ PCI_VDEVICE(MELLANOX, 4116) }, /* ConnectX-4 VF */
-	{ PCI_VDEVICE(MELLANOX, 4117) }, /* ConnectX-4LX */
-	{ PCI_VDEVICE(MELLANOX, 4118) }, /* ConnectX-4LX VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1011) }, /* Connect-IB */
+	{ PCI_VDEVICE(MELLANOX, 0x1012) }, /* Connect-IB VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1013) }, /* ConnectX-4 */
+	{ PCI_VDEVICE(MELLANOX, 0x1014) }, /* ConnectX-4 VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1015) }, /* ConnectX-4LX */
+	{ PCI_VDEVICE(MELLANOX, 0x1016) }, /* ConnectX-4LX VF */
 	{ 0, }
 };
 
-- 
1.9.3
