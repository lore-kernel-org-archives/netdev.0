From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] ethernet: Cocci spatch "ptr_ret.spatch"
Date: Sat, 01 Jun 2013 11:51:52 +0200
Message-ID: <1370080312.29224.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -551,9 +551,7 @@ static struct net_device *apne_dev;
 static int __init apne_module_init(void)
 {
 	apne_dev = apne_probe(-1);
-	if (IS_ERR(apne_dev))
-		return PTR_ERR(apne_dev);
-	return 0;
+	return PTR_RET(apne_dev);
 }
 
 static void __exit apne_module_exit(void)
