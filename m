From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 1/4] stmmac: pci: use defined constant instead of magic number
Date: Wed,  5 Nov 2014 12:27:26 +0200
Message-ID: <1415183249-9231-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30633 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbaKEK2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:28:07 -0500
In-Reply-To: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last standard PCI resource is defined as PCI_STD_RESOURCE_END. Thus, we
could use it instead of plain integer.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index e17a970..e45794d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -90,7 +90,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	}
 
 	/* Get the base address of device */
-	for (i = 0; i <= 5; i++) {
+	for (i = 0; i <= PCI_STD_RESOURCE_END; i++) {
 		if (pci_resource_len(pdev, i) == 0)
 			continue;
 		addr = pci_iomap(pdev, i, 0);
-- 
2.1.1
