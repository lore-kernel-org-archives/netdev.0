From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 05/11] cxgb3: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:54 +0300
Message-ID: <1341148740-7375-6-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Divy Le Ray" <divy@chelsio.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4181 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932329Ab2GANUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:41 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index abb6ce7..9b08749 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3050,7 +3050,7 @@ static struct pci_error_handlers t3_err_handler = {
 static void set_nqsets(struct adapter *adap)
 {
 	int i, j = 0;
-	int num_cpus = num_online_cpus();
+	int num_cpus = netif_get_num_default_rss_queues();
 	int hwports = adap->params.nports;
 	int nqsets = adap->msix_nvectors - 1;
 
-- 
1.7.9.rc2
