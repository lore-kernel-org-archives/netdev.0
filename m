From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/sh_eth.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:04:07 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4C8@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752404AbZL1XEH@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index ca62850..ed52c00 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1473,13 +1473,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	if (ret)
 		goto out_unregister;
 
-	/* pritnt device infomation */
-	pr_info("Base address at 0x%x, ",
-	       (u32)ndev->base_addr);
-
-	for (i = 0; i < 5; i++)
-		printk("%02X:", ndev->dev_addr[i]);
-	printk("%02X, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
+	/* print device infomation */
+	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
+	       (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
 	platform_set_drvdata(pdev, ndev);
  
