From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: pci: Fix the FW ready mask length
Date: Thu,  3 Nov 2016 09:41:55 +0100
Message-ID: <1478162515-2910-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34323 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755631AbcKCIl6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 04:41:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id p190so6823581wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 01:41:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

The system-status register is actually 16-bit wide and not 8 bit-wide.

Fixes: 233fa44bd67ae ("mlxsw: pci: Implement reset done check")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
index 708736f..d147ddd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
@@ -60,7 +60,7 @@
 #define MLXSW_PCI_SW_RESET_RST_BIT		BIT(0)
 #define MLXSW_PCI_SW_RESET_TIMEOUT_MSECS	5000
 #define MLXSW_PCI_FW_READY			0xA1844
-#define MLXSW_PCI_FW_READY_MASK			0xFF
+#define MLXSW_PCI_FW_READY_MASK			0xFFFF
 #define MLXSW_PCI_FW_READY_MAGIC		0x5E
 
 #define MLXSW_PCI_DOORBELL_SDQ_OFFSET		0x000
-- 
2.7.4
