From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 7/7] tehuti: shorten PCI device table.
Date: Fri, 30 Sep 2011 12:39:23 +0200
Message-ID: <20110930103923.GH26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54254 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab1I3Kk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:40:56 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/tehuti/tehuti.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 371ab7a..1151cf9 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -67,10 +67,10 @@
 #include "tehuti.h"
 
 static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
-	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0}
+	{ PCI_VDEVICE(TEHUTI, 0x3009), },
+	{ PCI_VDEVICE(TEHUTI, 0x3010), },
+	{ PCI_VDEVICE(TEHUTI, 0x3014), },
+	{ 0 }
 };
 
 MODULE_DEVICE_TABLE(pci, bdx_pci_tbl);
-- 
1.7.6.2
