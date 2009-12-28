From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/smc911x.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:09:52 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4C9@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752346AbZL1XJu@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 44ebbaa..3c5a4f5 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2017,10 +2017,8 @@ static int __devinit smc911x_probe(struct net_device *dev)
 					"set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: ", dev->name);
-			for (i = 0; i < 5; i++)
-				printk("%2.2x:", dev->dev_addr[i]);
-			printk("%2.2x\n", dev->dev_addr[5]);
+			printk("%s: Ethernet addr: %pM\n",
+				dev->name, dev->dev_addr);
 		}
 
 		if (lp->phy_type == 0) { 
