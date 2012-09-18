From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 3/5] ucc_geth: Fix two gcc warnings
Date: Tue, 18 Sep 2012 18:56:23 +0200
Message-ID: <1347987385-19071-3-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:58026 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807Ab2IRQ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 12:56:37 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 9F96E2581E4
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 18:56:36 +0200 (CEST)
In-Reply-To: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ucc_geth.c: In function 'ucc_geth_startup':
ucc_geth.c:3092:45: warning: comparison between 'enum qe_fltr_largest_external_tbl_lookup_key_size' and 'enum qe_fltr_tbl_lookup_key_size'

ucc_geth.c:3096:45: warning: comparison between 'enum qe_fltr_largest_external_tbl_lookup_key_size' and 'enum qe_fltr_tbl_lookup_key_size'

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5f1460a..7d60b95 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3074,11 +3074,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->rxExtendedFiltering) {
 		size += THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING;
 		if (ug_info->largestexternallookupkeysize ==
-		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
+		    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
 			size +=
 			    THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_8;
 		if (ug_info->largestexternallookupkeysize ==
-		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
+		    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
 			size +=
 			    THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_16;
 	}
-- 
1.7.8.6
