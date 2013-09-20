From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Remove if 0'd code
Date: Fri, 20 Sep 2013 16:46:58 -0700
Message-ID: <1379720822-6500-5-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4807 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741Ab3ITXrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:14 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 34cd0f5..01aa405 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17067,10 +17067,6 @@ static int tg3_test_dma(struct tg3 *tp)
 
 	tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
 
-#if 0
-	/* Unneeded, already done by tg3_get_invariants.  */
-	tg3_switch_clocks(tp);
-#endif
 
 	if (tg3_asic_rev(tp) != ASIC_REV_5700 &&
 	    tg3_asic_rev(tp) != ASIC_REV_5701)
@@ -17098,20 +17094,6 @@ static int tg3_test_dma(struct tg3 *tp)
 			break;
 		}
 
-#if 0
-		/* validate data reached card RAM correctly. */
-		for (i = 0; i < TEST_BUFFER_SIZE / sizeof(u32); i++) {
-			u32 val;
-			tg3_read_mem(tp, 0x2100 + (i*4), &val);
-			if (le32_to_cpu(val) != p[i]) {
-				dev_err(&tp->pdev->dev,
-					"%s: Buffer corrupted on device! "
-					"(%d != %d)\n", __func__, val, i);
-				/* ret = -ENODEV here? */
-			}
-			p[i] = 0;
-		}
-#endif
 		/* Now read it back. */
 		ret = tg3_do_test_dma(tp, buf, buf_dma, TEST_BUFFER_SIZE, false);
 		if (ret) {
-- 
1.8.1.4
