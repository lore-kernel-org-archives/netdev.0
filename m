From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 07/11] myri10ge: set maximal number of default
 RSS queues
Date: Sun, 1 Jul 2012 16:18:56 +0300
Message-ID: <1341148740-7375-8-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <mason@myri.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3426 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726Ab2GANUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:47 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jon Mason <mason@myri.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 90153fc..fa85cf1 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3775,7 +3775,7 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 
 	mgp->num_slices = 1;
 	msix_cap = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	ncpus = num_online_cpus();
+	ncpus = netif_get_num_default_rss_queues();
 
 	if (myri10ge_max_slices == 1 || msix_cap == 0 ||
 	    (myri10ge_max_slices == -1 && ncpus < 2))
-- 
1.7.9.rc2
