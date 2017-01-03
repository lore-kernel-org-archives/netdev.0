From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc-falcon: declare module version (same as ethtool
 drvinfo version)
Date: Tue, 3 Jan 2017 15:46:15 +0000
Message-ID: <f718c632-3a59-b841-1836-0a6f04553489@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:65001 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759089AbdACPrl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:47:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon/efx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index 438ef9e..ec3ac0e 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -3348,3 +3348,4 @@ MODULE_AUTHOR("Solarflare Communications and "
 MODULE_DESCRIPTION("Solarflare Falcon network driver");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, ef4_pci_table);
+MODULE_VERSION(EF4_DRIVER_VERSION);
