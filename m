From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 9/9] net/mlx4_en: Change Connect-X description in kconfig
Date: Fri, 28 Feb 2014 08:00:09 +0200
Message-ID: <1393567209-16358-10-git-send-email-amirv@mellanox.com>
References: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49364 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750873AbaB1GA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 01:00:29 -0500
In-Reply-To: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

The mlx4_en driver support also 1Gbit and 40Gbit Ethernet devices,
changed the driver description in the menuconfig to reflect that.


Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 563495d..1a6e188 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config MLX4_EN
-	tristate "Mellanox Technologies 10Gbit Ethernet support"
+	tristate "Mellanox Technologies 1/10/40Gbit Ethernet support"
 	depends on PCI
 	select MLX4_CORE
 	select PTP_1588_CLOCK
-- 
1.8.3.4
