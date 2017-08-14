From: Ohad Oz <ohado@mellanox.com>
Subject: [patch v2 1/2] Allow Mellanox switch devices to be configured if only I2C bus is set
Date: Mon, 14 Aug 2017 15:38:21 +0000
Message-ID: <1502725102-182550-2-git-send-email-ohado@mellanox.com>
References: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com,
        Ohad Oz <ohado@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46377 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752431AbdHNNlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 09:41:24 -0400
In-Reply-To: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mellanox switches (mlxsw) supports I2C systems without PCI, in order to
give the ability to the users to use such functionality, there is need
to update Kconfig.

Signed-off-by: Ohad Oz <ohado@mellanox.com>
Acked-by: Leon Romanovsky <leonro@mellanox.com>
---
v1->v2
Comments pointed out by Leon Romanovsky <leonro@mellanox.com>
- Rephrase change description.
---
 drivers/net/ethernet/mellanox/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 84a2007..0949741 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_MELLANOX
 	bool "Mellanox devices"
 	default y
-	depends on PCI
+	depends on PCI || I2C
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
-- 
2.1.4
