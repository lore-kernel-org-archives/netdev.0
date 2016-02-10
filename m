From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 5/5] bnxt_en: Reduce default ring sizes.
Date: Wed, 10 Feb 2016 17:33:50 -0500
Message-ID: <1455143630-30140-6-git-send-email-mchan@broadcom.com>
References: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:45680
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953AbcBJWdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:52 -0500
In-Reply-To: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current default tx ring size of 512 causes an extra page to be
allocated for the tx ring with only 1 entry in it.  Reduce it to
511.  The default rx ring size is also reduced to 511 to use less
memory by default.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 9b4866c..2be51b3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -411,8 +411,8 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_NUM_TESTS(bp)	0
 
-#define BNXT_DEFAULT_RX_RING_SIZE	1023
-#define BNXT_DEFAULT_TX_RING_SIZE	512
+#define BNXT_DEFAULT_RX_RING_SIZE	511
+#define BNXT_DEFAULT_TX_RING_SIZE	511
 
 #define MAX_TPA		64
 
-- 
1.8.3.1
