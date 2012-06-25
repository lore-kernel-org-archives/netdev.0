From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 07/14] myri10ge: set maximal number of
 default RSS queues
Date: Mon, 25 Jun 2012 14:45:38 +0300
Message-ID: <1340624745-8650-8-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <mason@myri.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4180 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095Ab2FYLsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:48:03 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
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
