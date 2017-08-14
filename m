From: Ohad Oz <ohado@mellanox.com>
Subject: [patch v2 2/2] Change Kconfig description
Date: Mon, 14 Aug 2017 15:38:22 +0000
Message-ID: <1502725102-182550-3-git-send-email-ohado@mellanox.com>
References: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com,
        Ohad Oz <ohado@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46316 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752411AbdHNNlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 09:41:20 -0400
In-Reply-To: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch apply Mellanox network vendor which includes:
- Mellanox card devices: ConnectX-4, ConnectX-5 and Connect-IB cards.
- Mellanox switch device: SwitchX-2 Switch-IB, Spectrum.
Therefore rephrasing help.

Signed-off-by: Ohad Oz <ohado@mellanox.com>
Acked-by: Leon Romanovsky <leonro@mellanox.com>
---
v1->v2
Comments pointed out by Leon Romanovsky <leonro@mellanox.com>
- Include RDMA as part of mlnx network devices.
- Rephrase change description
---
 drivers/net/ethernet/mellanox/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 0949741..872548c 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -7,7 +7,8 @@ config NET_VENDOR_MELLANOX
 	default y
 	depends on PCI || I2C
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  If you have a network (Ethernet or RDMA) device belonging to this
+	  class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-- 
2.1.4
