From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Add missing braces to ath10k_pci_tx_pipe_cleanup
Date: Wed, 4 Sep 2013 23:51:28 -0400
Message-ID: <20130905035128.GA15824@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@qca.qualcomm.com, linville@tuxdriver.com,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3IEDwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 23:52:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indentation here implies this was meant to be a multi-statement if, but it lacks the braces.

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 33af467..31b69d3 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -1200,7 +1200,7 @@ static void ath10k_pci_tx_pipe_cleanup(struct hif_ce_pipe_info *pipe_info)
 
 	while (ath10k_ce_cancel_send_next(ce_hdl, (void **)&netbuf,
 					  &ce_data, &nbytes, &id) == 0) {
-		if (netbuf != CE_SENDLIST_ITEM_CTXT)
+		if (netbuf != CE_SENDLIST_ITEM_CTXT) {
 			/*
 			 * Indicate the completion to higer layer to free
 			 * the buffer
@@ -1209,6 +1209,7 @@ static void ath10k_pci_tx_pipe_cleanup(struct hif_ce_pipe_info *pipe_info)
 			ar_pci->msg_callbacks_current.tx_completion(ar,
 								    netbuf,
 								    id);
+		}
 	}
 }
 
