From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next 2/3] bnx2: Fix for Chip Initialization
Date: Tue, 17 Feb 2015 19:26:19 -0500
Message-ID: <1424219180-29028-3-git-send-email-rasesh.mody@qlogic.com>
References: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:50165 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730AbbBRBF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:05:59 -0500
In-Reply-To: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not enable filter SORT MODE in chip init routine. This patch addresses an
issue where BCM5716 sporadically drops packets when changing multicast list.

Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2305de2..4b48e21 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -4984,8 +4984,6 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	bp->idle_chk_status_idx = 0xffff;
 
-	bp->rx_mode = BNX2_EMAC_RX_MODE_SORT_MODE;
-
 	/* Set up how to generate a link change interrupt. */
 	BNX2_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
-- 
1.8.2.3
