From: Ohad Oz <ohado@mellanox.com>
Subject: [patch v1 1/2] Allow Mellanox network vendor to be configured if only I2C bus is configured
Date: Thu, 10 Aug 2017 17:11:51 +0000
Message-ID: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com,
        Ohad Oz <ohado@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47470 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752059AbdHJPPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 11:15:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch allows Mellanox devices on system with no PCI, but with I2C only.

Signed-off-by: Ohad Oz <ohado@mellanox.com>
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
2.8.0
