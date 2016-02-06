From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:  Completition on Enable bios support.
Date: Sat,  6 Feb 2016 08:49:36 +0200
Message-ID: <1454741376-4897-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-244.residential.rdsnet.ro ([5.14.227.244]:35012 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbcBFGuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 01:50:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2e83059..1d119a6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7918,7 +7918,9 @@ static void rtl_wol_shutdown_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_11:
 	case RTL_GIGA_MAC_VER_12:
 	case RTL_GIGA_MAC_VER_17:
+#ifndef CONFIG_BIOS_SUPPORT
 		pci_clear_master(tp->pci_dev);
+#endif
 
 		RTL_W8(ChipCmd, CmdRxEnb);
 		/* PCI commit */
-- 
2.5.0
