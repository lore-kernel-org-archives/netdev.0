From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 08/14] tg3: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:39 +0300
Message-ID: <1340624745-8650-9-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4326 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064Ab2FYLry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:47:54 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..6cbab03 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9908,7 +9908,7 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	int i, rc;
 	struct msix_entry msix_ent[tp->irq_max];
 
-	tp->irq_cnt = num_online_cpus();
+	tp->irq_cnt = netif_get_num_default_rss_queues();
 	if (tp->irq_cnt > 1) {
 		/* We want as many rx rings enabled as there are cpus.
 		 * In multiqueue MSI-X mode, the first MSI-X vector
-- 
1.7.9.rc2
