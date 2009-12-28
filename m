From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/octeon/octeon_mgmt.c: use %pM to shown MAC address
Date: Mon, 28 Dec 2009 17:54:25 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F4C5@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6ob111.obsmtp.com ([64.18.1.26]:46939 "HELO psmtp.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751519AbZL1WyV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 17:54:21 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 050538b..6fd8789 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -1119,11 +1119,8 @@ static int __init octeon_mgmt_probe(struct platform_device *pdev)
 
 	if (p->port >= octeon_bootinfo->mac_addr_count)
 		dev_err(&pdev->dev,
-			"Error %s: Using MAC outside of the assigned range: "
-			"%02x:%02x:%02x:%02x:%02x:%02x\n", netdev->name,
-			netdev->dev_addr[0], netdev->dev_addr[1],
-			netdev->dev_addr[2], netdev->dev_addr[3],
-			netdev->dev_addr[4], netdev->dev_addr[5]);
+			"Error %s: Using MAC outside of the assigned range: %pM\n",
+			netdev->name, netdev->dev_addr);
 
 	if (register_netdev(netdev))
 		goto err; 
