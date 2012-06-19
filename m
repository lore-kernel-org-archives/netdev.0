From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 13/14] Fix broadcom/bnx2
Date: Tue, 19 Jun 2012 18:14:07 +0300
Message-ID: <1340118848-30978-14-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4204 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754379Ab2FSPQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:47 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9b69a62..09e1f76 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6246,7 +6246,7 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 static int
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
-	int cpus = num_online_cpus();
+	int cpus = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 	int msix_vecs;
 
 	if (!bp->num_req_rx_rings)
-- 
1.7.9.rc2
