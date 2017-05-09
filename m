From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/4] net: stmmac: Delete an unnecessary return statement in
 stmmac_get_tx_hwtstamp()
Date: Tue, 9 May 2017 13:55:35 +0200
Message-ID: <4d8b60f5-5d5f-8fa1-a896-d48c2b054ec4@users.sourceforge.net>
References: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:51796 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752016AbdEILzz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 07:55:55 -0400
In-Reply-To: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 13:36:04 +0200

The script "checkpatch.pl" pointed information out like the following.

WARNING: void function return statements are not generally useful

Thus remove such a statement in the affected function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4fa95234978c..9ab4cbfa67f1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -445,8 +445,6 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		/* pass tstamp to stack */
 		skb_tstamp_tx(skb, &shhwtstamp);
 	}
-
-	return;
 }
 
 /* stmmac_get_rx_hwtstamp - get HW RX timestamps
-- 
2.12.2
