From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 7/7] 8139cp: use PCI_DEVICE() to shorten the PCI device table
Date: Thu, 31 Aug 2006 22:53:24 +0200
Message-ID: <20060831205324.GG14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:62853 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750816AbWHaU4H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:56:07 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

cccb20d3a9b7c6d4b6e1b52ee02814e6094aaa12
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a123d28..bbdaa18 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -406,10 +406,8 @@ static int cp_set_eeprom(struct net_devi
 			 struct ethtool_eeprom *eeprom, u8 *data);
 
 static struct pci_device_id cp_pci_tbl[] = {
-	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8139,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
-	{ PCI_VENDOR_ID_TTTECH, PCI_DEVICE_ID_TTTECH_MC322,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, },
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	PCI_DEVICE_ID_REALTEK_8139), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_TTTECH,	PCI_DEVICE_ID_TTTECH_MC322), },
 	{ },
 };
 MODULE_DEVICE_TABLE(pci, cp_pci_tbl);
-- 
1.3.1

