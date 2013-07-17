From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v3 4/6] bnx2x: fix memory leak in VF
Date: Thu, 18 Jul 2013 01:00:38 +0300
Message-ID: <1374098440-27877-5-git-send-email-dmitry@broadcom.com>
References: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1537 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756375Ab3GQWB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 18:01:28 -0400
In-Reply-To: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 95861ef..44104fb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3463,7 +3463,7 @@ int bnx2x_vf_pci_alloc(struct bnx2x *bp)
 alloc_mem_err:
 	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->vf2pf_mbox_mapping,
 		       sizeof(struct bnx2x_vf_mbx_msg));
-	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->vf2pf_mbox_mapping,
+	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->pf2vf_bulletin_mapping,
 		       sizeof(union pf_vf_bulletin));
 	return -ENOMEM;
 }
-- 
1.8.1.4
