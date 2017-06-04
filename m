From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath6kl: fix spelling mistake: "Indicat" -> "Indicate"
Date: Sun,  4 Jun 2017 17:36:08 +0100
Message-ID: <20170604163608.24894-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55867 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdFDQgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 12:36:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in ath6kl_dbg debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath6kl/htc_pipe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index d127a08d60df..d4fd9e40fffb 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -383,7 +383,7 @@ static enum htc_send_queue_result htc_try_send(struct htc_target *target,
 			list_for_each_entry_safe(packet, tmp_pkt,
 						 txq, list) {
 				ath6kl_dbg(ATH6KL_DBG_HTC,
-					   "%s: Indicat overflowed TX pkts: %p\n",
+					   "%s: Indicate overflowed TX pkts: %p\n",
 					   __func__, packet);
 				action = ep->ep_cb.tx_full(ep->target, packet);
 				if (action == HTC_SEND_FULL_DROP) {
-- 
2.11.0
