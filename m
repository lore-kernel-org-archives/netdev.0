From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: declare module version (same as ethtool drvinfo
 version)
Date: Tue, 3 Jan 2017 15:46:00 +0000
Message-ID: <3453b0f7-a522-e332-590a-e04d4d4b50a5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:5308 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758785AbdACPuV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:50:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5a5dcad..bbbed2e 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3585,3 +3585,4 @@ MODULE_AUTHOR("Solarflare Communications and "
 MODULE_DESCRIPTION("Solarflare network driver");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, efx_pci_table);
+MODULE_VERSION(EFX_DRIVER_VERSION);
