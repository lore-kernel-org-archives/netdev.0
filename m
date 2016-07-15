From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [PATCH 1/2] wan/fsl_ucc_hdlc: remove reduplicative freed memory 'uhdlc_priv'
Date: Fri, 15 Jul 2016 10:38:24 +0800
Message-ID: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xiaobo.xie@nxp.com>, Zhao Qiang <qiang.zhao@nxp.com>
To: <davem@davemloft.net>, <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'uhdlc_priv' has freed twice, drop the first one.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 19174ac..e2b225d 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -1127,7 +1127,6 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 
 err_hdlc_init:
 err_miss_tsa_property:
-	kfree(uhdlc_priv);
 	if (uhdlc_priv->tsa)
 		kfree(utdm);
 err_alloc_utdm:
-- 
2.1.0.27.g96db324
