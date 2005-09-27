From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 4/3] rose: fix typo (regeistration)
Date: Wed, 28 Sep 2005 02:25:32 +0400
Message-ID: <20050927222532.GD25047@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/rose/af_rose.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-rose-003/net/rose/af_rose.c
+++ linux-rose-004/net/rose/af_rose.c
@@ -1508,7 +1508,7 @@ static int __init rose_proto_init(void)
 		}
 		rc = register_netdev(dev);
 		if (rc) {
-			printk(KERN_ERR "ROSE: netdevice regeistration failed\n");
+			printk(KERN_ERR "ROSE: netdevice registration failed\n");
 			free_netdev(dev);
 			goto fail;
 		}

