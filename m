From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 10/34]bnx2x: Compilation issue on IA64
Date: Wed, 14 Jan 2009 18:43:11 +0200
Message-ID: <1231951391.11301.131.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2391 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763203AbZANQn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4993707..ba56d1c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1199,7 +1199,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 
 #ifdef BNX2X_STOP_ON_ERROR
 	fp->tpa_queue_used |= (1 << queue);
-#ifdef __powerpc64__
+#if (defined __powerpc64__) || (defined _ASM_IA64_TYPES_H)
 	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
 #else
 	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
-- 
1.5.4.3




