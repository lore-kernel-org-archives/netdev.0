From: Ohad Oz <ohado@mellanox.com>
Subject: [patch v1 2/2] Change Kconfig description
Date: Thu, 10 Aug 2017 17:11:52 +0000
Message-ID: <1502385112-103765-2-git-send-email-ohado@mellanox.com>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com,
        Ohad Oz <ohado@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47471 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752231AbdHJPPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 11:15:11 -0400
In-Reply-To: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mellanox devices can be cards or switch therefore naming it device.

Signed-off-by: Ohad Oz <ohado@mellanox.com>
---
 drivers/net/ethernet/mellanox/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 0949741..01c3623 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -7,7 +7,7 @@ config NET_VENDOR_MELLANOX
 	default y
 	depends on PCI || I2C
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  If you have a network (Ethernet) device belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-- 
2.8.0
