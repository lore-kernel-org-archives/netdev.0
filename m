From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 3/8] net/wan/fsl_ucc_hdlc: fix wrong indentation
Date: Wed, 17 May 2017 17:24:34 +0200
Message-ID: <20170517152439.8817-3-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47314 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754021AbdEQPbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:32 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 6ef6d719545d..1a60897767d9 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -535,7 +535,7 @@ static int ucc_hdlc_poll(struct napi_struct *napi, int budget)
 
 	/* Tx event processing */
 	spin_lock(&priv->lock);
-		hdlc_tx_done(priv);
+	hdlc_tx_done(priv);
 	spin_unlock(&priv->lock);
 
 	howmany = 0;
-- 
2.12.0.rc1
