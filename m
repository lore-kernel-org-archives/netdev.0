From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] rtlwifi: rtl8192de: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:11:34 +0800
Message-ID: <CAPgLHd86W5X=Tb_fXoz_Ood-w_s282QNePTXG9m_6ESdG-rG2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:45812 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab2H1NLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:11:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index 895ae6c..a3aede0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -570,8 +570,7 @@ static bool _rtl92d_cmd_send_packet(struct ieee80211_hw *hw,
 
 	ring = &rtlpci->tx_ring[BEACON_QUEUE];
 	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
+	kfree_skb(pskb);
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	pdesc = &ring->desc[idx];
 	/* discard output from call below */
