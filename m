From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/2] atm: Delete an error message for a failed memory
 allocation in adummy_init()
Date: Sun, 1 Oct 2017 21:49:30 +0200
Message-ID: <500829be-1d9b-90b0-c675-854463055c97@users.sourceforge.net>
References: <8fe2ca8a-e1f7-d492-db69-c52b66143ac6@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8fe2ca8a-e1f7-d492-db69-c52b66143ac6@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Oct 2017 21:31:32 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/adummy.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index 8d98130ecd40..94b73ddfb731 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -150,7 +150,6 @@ static int __init adummy_init(void)
 	adummy_dev = kzalloc(sizeof(struct adummy_dev),
 						   GFP_KERNEL);
 	if (!adummy_dev) {
-		printk(KERN_ERR DEV_LABEL ": kzalloc() failed\n");
 		err = -ENOMEM;
 		goto out;
 	}
-- 
2.14.2
