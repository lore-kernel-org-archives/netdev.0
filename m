From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 3/8] net/mlx5_core: Add ConnectX-5 to list of supported devices
Date: Fri, 22 Apr 2016 00:33:02 +0300
Message-ID: <1461274387-10653-4-git-send-email-saeedm@mellanox.com>
References: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60190 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752348AbcDUVeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 17:34:05 -0400
In-Reply-To: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add the upcoming ConnectX-5 devices (PF and VF) to the list of
supported devices by the mlx5 driver.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3f3b2fa..ddd352a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1459,6 +1459,8 @@ static const struct pci_device_id mlx5_core_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x1014), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4 VF */
 	{ PCI_VDEVICE(MELLANOX, 0x1015) },			/* ConnectX-4LX */
 	{ PCI_VDEVICE(MELLANOX, 0x1016), MLX5_PCI_DEV_IS_VF},	/* ConnectX-4LX VF */
+	{ PCI_VDEVICE(MELLANOX, 0x1017) },			/* ConnectX-5 */
+	{ PCI_VDEVICE(MELLANOX, 0x1018), MLX5_PCI_DEV_IS_VF},	/* ConnectX-5 VF */
 	{ 0, }
 };
 
-- 
1.7.1
