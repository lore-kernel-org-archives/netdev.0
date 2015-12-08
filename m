From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath9k: fix inconsistent indenting on return statement
Date: Tue,  8 Dec 2015 23:49:31 +0000
Message-ID: <1449618571-4087-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39828 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbbLHXtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 18:49:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

minor change, indenting is one tab out.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath9k/xmit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 3e3dac3..f796d90 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2894,7 +2894,7 @@ int ath9k_tx99_send(struct ath_softc *sc, struct sk_buff *skb,
 		if (skb_headroom(skb) < padsize) {
 			ath_dbg(common, XMIT,
 				"tx99 padding failed\n");
-		return -EINVAL;
+			return -EINVAL;
 		}
 
 		skb_push(skb, padsize);
-- 
2.6.2
