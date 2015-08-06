From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/7] mlxsw: Make pci module dependent on HAS_DMA and HAS_IOMEM
Date: Thu,  6 Aug 2015 16:41:54 +0200
Message-ID: <1438872118-16869-4-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33538 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810AbbHFOmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:10 -0400
Received: by wijp15 with SMTP id p15so25510950wij.0
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:09 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This resolves compile errors on um-allyesconfig.

Note that there are many other drivers which have the same issue.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 8d1080d..2941d9c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -12,7 +12,7 @@ config MLXSW_CORE
 
 config MLXSW_PCI
 	tristate "PCI bus implementation for Mellanox Technologies Switch ASICs"
-	depends on PCI && MLXSW_CORE
+	depends on PCI && HAS_DMA && HAS_IOMEM && MLXSW_CORE
 	default m
 	---help---
 	  This is PCI bus implementation for Mellanox Technologies Switch ASICs.
-- 
1.9.3
