From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: qca8k: use mdio_module_driver to simplify the code
Date: Wed, 21 Sep 2016 15:05:05 +0000
Message-ID: <1474470305-31840-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35707 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935011AbcIUPFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:05:11 -0400
Received: by mail-pf0-f196.google.com with SMTP id 6so2501502pfl.2
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:05:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

mdio_module_driver() makes the code simpler by eliminating
boilerplate code.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/qca8k.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 7f3f178..022a6bc2 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -1040,19 +1040,7 @@ static struct mdio_driver qca8kmdio_driver = {
 	},
 };
 
-static int __init
-qca8kmdio_driver_register(void)
-{
-	return mdio_driver_register(&qca8kmdio_driver);
-}
-module_init(qca8kmdio_driver_register);
-
-static void __exit
-qca8kmdio_driver_unregister(void)
-{
-	mdio_driver_unregister(&qca8kmdio_driver);
-}
-module_exit(qca8kmdio_driver_unregister);
+mdio_module_driver(qca8kmdio_driver);
 
 MODULE_AUTHOR("Mathieu Olivari, John Crispin <john@phrozen.org>");
 MODULE_DESCRIPTION("Driver for QCA8K ethernet switch family");
