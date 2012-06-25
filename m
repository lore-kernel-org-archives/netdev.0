From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 09/14] bnx2: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:40 +0300
Message-ID: <1340624745-8650-10-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4190 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132Ab2FYLsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:48:02 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9b69a62..3f49285 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6246,7 +6246,7 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 static int
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
-	int cpus = num_online_cpus();
+	int cpus = netif_get_num_default_rss_queues();
 	int msix_vecs;
 
 	if (!bp->num_req_rx_rings)
-- 
1.7.9.rc2
