From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: wan: slic_ds26522: Use module_spi_driver to simplify the code
Date: Mon, 17 Oct 2016 14:50:45 +0000
Message-ID: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34331 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933143AbcJQOvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:51:01 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so12949222pfz.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 07:51:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

module_spi_driver() makes the code simpler by eliminating
boilerplate code.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/wan/slic_ds26522.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/wan/slic_ds26522.c b/drivers/net/wan/slic_ds26522.c
index b776a0a..8f782f1 100644
--- a/drivers/net/wan/slic_ds26522.c
+++ b/drivers/net/wan/slic_ds26522.c
@@ -249,15 +249,4 @@ static struct spi_driver slic_ds26522_driver = {
 	.id_table = slic_ds26522_id,
 };
 
-static int __init slic_ds26522_init(void)
-{
-	return spi_register_driver(&slic_ds26522_driver);
-}
-
-static void __exit slic_ds26522_exit(void)
-{
-	spi_unregister_driver(&slic_ds26522_driver);
-}
-
-module_init(slic_ds26522_init);
-module_exit(slic_ds26522_exit);
+module_spi_driver(slic_ds26522_driver);
