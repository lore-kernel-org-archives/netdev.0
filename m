From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 09/11] bnx2: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:58 +0300
Message-ID: <1341148740-7375-10-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4176 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755721Ab2GANUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:46 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9eb7624..1901da1 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6250,7 +6250,7 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 static int
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
-	int cpus = num_online_cpus();
+	int cpus = netif_get_num_default_rss_queues();
 	int msix_vecs;
 
 	if (!bp->num_req_rx_rings)
-- 
1.7.9.rc2
