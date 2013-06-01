From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] netdev: Cocci spatch "ptr_ret.spatch"
Date: Sat, 01 Jun 2013 11:55:42 +0200
Message-ID: <1370080542.29224.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -1527,9 +1527,7 @@ int __init init_module(void)
 	if (debug >= 0)
 		i596_debug = debug;
 	dev_82596 = i82596_probe(-1);
-	if (IS_ERR(dev_82596))
-		return PTR_ERR(dev_82596);
-	return 0;
+	return PTR_RET(dev_82596);
 }
 
 void __exit cleanup_module(void)
