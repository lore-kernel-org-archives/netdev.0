From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/sunvnet.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:14:35 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4CA@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752470AbZL1XOd@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index bc74db0..d65764e 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1062,10 +1062,7 @@ static struct vnet * __devinit vnet_new(const u64 *local_mac)
 		goto err_out_free_dev;
 	}
 
-	printk(KERN_INFO "%s: Sun LDOM vnet ", dev->name);
-
-	for (i = 0; i < 6; i++)
-		printk("%2.2x%c", dev->dev_addr[i], i == 5 ? '\n' : ':');
+	printk(KERN_INFO "%s: Sun LDOM vnet %pM\n", dev->name, dev->dev_addr);
 
 	list_add(&vp->list, &vnet_list);
  
