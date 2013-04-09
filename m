From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] mrf24j40: use module_spi_driver to simplify the code
Date: Tue, 9 Apr 2013 14:34:44 +0800
Message-ID: <CAPgLHd_Ci0u45-C0y7NV66zim8zZgBY+VjmW2iBdgG2OoL5CyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:44679 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab3DIGep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 02:34:45 -0400
Received: by mail-bk0-f54.google.com with SMTP id q16so3455505bkw.13
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 23:34:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

module_spi_driver() makes the code simpler by eliminating
boilerplate code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ieee802154/mrf24j40.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index ca00351..eca7165 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -756,18 +756,7 @@ static struct spi_driver mrf24j40_driver = {
 	.remove = mrf24j40_remove,
 };
 
-static int __init mrf24j40_init(void)
-{
-	return spi_register_driver(&mrf24j40_driver);
-}
-
-static void __exit mrf24j40_exit(void)
-{
-	spi_unregister_driver(&mrf24j40_driver);
-}
-
-module_init(mrf24j40_init);
-module_exit(mrf24j40_exit);
+module_spi_driver(mrf24j40_driver);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Alan Ott");
