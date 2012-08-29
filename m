From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next] r8169: add D-Link DGE-560T identifiers.
Date: Wed, 29 Aug 2012 21:40:37 +0200
Message-ID: <20120829194037.GB6389@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Neyuki Inaya <in@joblog.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34134 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab2H2T5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 15:57:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one includes a 8168. Not to be confused with the sky2 driven
one whose PCI vendor and device ID are the same.

Reported-by: Neyuki Inaya <in@joblog.ru>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

 The patch applies to Linus's branch as well.

 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b47d5b3..ab1cc56 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -288,6 +288,8 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
+	{ PCI_VENDOR_ID_DLINK,			0x4300,
+		PCI_VENDOR_ID_DLINK, 0x4b10,		 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
-- 
Ueimor
