From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/xilinx_emaclite.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 18:33:35 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4CE@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og115.obsmtp.com ([64.18.1.35]:40761 "HELO
	exprod6og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751364AbZL1Xdb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 18:33:31 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 8c777ba..f7fe1aa 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -925,11 +925,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	/* Set the MAC address in the EmacLite device */
 	xemaclite_set_mac_address(lp, ndev->dev_addr);
 
-	dev_info(dev,
-		 "MAC address is now %2x:%2x:%2x:%2x:%2x:%2x\n",
-		 ndev->dev_addr[0], ndev->dev_addr[1],
-		 ndev->dev_addr[2], ndev->dev_addr[3],
-		 ndev->dev_addr[4], ndev->dev_addr[5]);
+	dev_info(dev, "MAC address is now %pM\n", ndev->dev_addr);
 
 	ndev->netdev_ops = &xemaclite_netdev_ops;
 	ndev->flags &= ~IFF_MULTICAST; 
