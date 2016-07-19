From: Wei Yongjun <weiyj_lk@163.com>
Subject: [PATCH -next] wan/fsl_ucc_hdlc: use module_platform_driver to simplify the code
Date: Tue, 19 Jul 2016 11:25:16 +0000
Message-ID: <1468927516-32569-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:57503 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965AbcGSLZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 07:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

module_platform_driver() makes the code simpler by eliminating
boilerplate code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index b3861bf..3f6b218 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -1175,15 +1175,4 @@ static struct platform_driver ucc_hdlc_driver = {
 	},
 };
 
-static int __init ucc_hdlc_init(void)
-{
-	return platform_driver_register(&ucc_hdlc_driver);
-}
-
-static void __exit ucc_hdlc_exit(void)
-{
-	platform_driver_unregister(&ucc_hdlc_driver);
-}
-
-module_init(ucc_hdlc_init);
-module_exit(ucc_hdlc_exit);
+module_platform_driver(ucc_hdlc_driver);
