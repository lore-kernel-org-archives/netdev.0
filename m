From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/via-velocity.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:30:08 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4CD@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752533AbZL1XaH@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 4ceb441..cee8fa2 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2702,10 +2702,8 @@ static void __devinit velocity_print_info(struct velocity_info *vptr)
 	struct net_device *dev = vptr->dev;
 
 	printk(KERN_INFO "%s: %s\n", dev->name, get_chip_name(vptr->chip_id));
-	printk(KERN_INFO "%s: Ethernet Address: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X\n",
-		dev->name,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	printk(KERN_INFO "%s: Ethernet Address: %pM\n",
+		dev->name, dev->dev_addr);
 }
 
 static u32 velocity_get_link(struct net_device *dev) 
