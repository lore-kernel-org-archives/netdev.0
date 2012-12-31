From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 04/15] via-rhine: handle compile warnings (use PCI_VDEVICE macro).
Date: Mon, 31 Dec 2012 16:25:38 +0100
Message-ID: <1356967549-5056-5-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54124 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Gets rid of W=2 warnings
drivers/net/ethernet/via/via-rhine.c:274: warning: missing initializer
drivers/net/ethernet/via/via-rhine.c:274: warning: (near initialization for 'rhine_pci_tbl[0].class')

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 6be6566..2d410ec 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -271,10 +271,10 @@ enum rhine_quirks {
 #define IOSYNC	do { ioread8(ioaddr + StationAddr); } while (0)
 
 static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
-	{ 0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, },	/* VT86C100A */
-	{ 0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6102 */
-	{ 0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, },	/* 6105{,L,LOM} */
-	{ 0x1106, 0x3053, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6105M */
+	{ PCI_VDEVICE(VIA, 0x3043), 0 },	/* VT86C100A */
+	{ PCI_VDEVICE(VIA, 0x3065), 0 },	/* VT6102 */
+	{ PCI_VDEVICE(VIA, 0x3106), 0 },	/* 6105{,L,LOM} */
+	{ PCI_VDEVICE(VIA, 0x3053), 0 },	/* VT6105M */
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
-- 
1.7.2.5
