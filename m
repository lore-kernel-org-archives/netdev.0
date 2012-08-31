From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH #2 net-next 1/1] r8169: add D-Link DGE-560T identifiers.
Date: Fri, 31 Aug 2012 23:06:17 +0200
Message-ID: <20120831210617.GA11968@electric-eye.fr.zoreil.com>
References: <20120829194037.GB6389@electric-eye.fr.zoreil.com> <1346308591.17040.20.camel@deadeye.wl.decadent.org.uk> <20120831.162852.1143438231808755797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, in@joblog.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38347 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab2HaVXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 17:23:00 -0400
Content-Disposition: inline
In-Reply-To: <20120831.162852.1143438231808755797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one includes a 8168. Not to be confused with the sky2 driven
one whose PCI vendor and device ID are the same.

Reported-by: Neyuki Inaya <in@joblog.ru>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b47d5b3..0c96604 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -287,6 +287,8 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
+	{ PCI_VENDOR_ID_DLINK,			0x4300,
+		PCI_VENDOR_ID_DLINK, 0x4b10,		 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
-- 
Ueimor
