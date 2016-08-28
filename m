From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wan/fsl_ucc_hdlc: fix spelling mistake "prameter" -> "parameter"
Date: Sun, 28 Aug 2016 11:40:41 +0100
Message-ID: <20160828104041.9272-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Zhao Qiang <qiang.zhao@nxp.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_err message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 6f04445..5fbf83d 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -162,7 +162,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 				ALIGNMENT_OF_UCC_HDLC_PRAM);
 
 	if (priv->ucc_pram_offset < 0) {
-		dev_err(priv->dev, "Can not allocate MURAM for hdlc prameter.\n");
+		dev_err(priv->dev, "Can not allocate MURAM for hdlc parameter.\n");
 		ret = -ENOMEM;
 		goto free_tx_bd;
 	}
-- 
2.9.3
