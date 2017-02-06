From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next v2] net: wan: slic_ds26522: Use module_spi_driver to simplify the code
Date: Mon,  6 Feb 2017 15:25:52 +0000
Message-ID: <20170206152552.8549-1-weiyj.lk@gmail.com>
References: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        Zhao Qiang <qiang.zhao@nxp.com>,
        Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36804 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752279AbdBFP0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:26:01 -0500
Received: by mail-pf0-f196.google.com with SMTP id 19so7104008pfo.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:26:00 -0800 (PST)
In-Reply-To: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
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
index 9d9b4e0..2cdcee2 100644
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
