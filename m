From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 9/9] net/mlx4_en: Change Connect-X description in kconfig
Date: Thu, 27 Feb 2014 14:27:06 +0200
Message-ID: <1393504026-13384-10-git-send-email-amirv@mellanox.com>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53587 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752638AbaB0M1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 07:27:23 -0500
In-Reply-To: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

The mlx4_en driver support also 1Gbit and 40Gbit Ethernet devices, changed the
driver description in the menuconfig to reflect that.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>

---
 drivers/net/ethernet/mellanox/mlx4/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 563495d..56efd13 100644
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
