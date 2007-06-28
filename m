From: Maik Hampel <m.hampel@gmx.de>
Subject: [PATCH] myri10ge: SET_NETDEV_DEV()
Date: Thu, 28 Jun 2007 17:07:26 +0200
Message-ID: <1183043246.2659.19.camel@c64>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:52177 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755855AbXF1PHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 11:07:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SET_NETDEV_DEV() in myri10ge to create the "/sys/class/net/<if>/device"
symlink.

Signed-off-by: Maik Hampel <m.hampel@gmx.de>

diff -Naur a/drivers/net/myri10ge/myri10ge.c
b/drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c	2007-06-28 16:04:41.000000000
+0200
+++ b/drivers/net/myri10ge/myri10ge.c	2007-06-28 16:31:24.000000000
+0200
@@ -2854,6 +2854,8 @@
 		return -ENOMEM;
 	}
 
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
 	mgp = netdev_priv(netdev);
 	memset(mgp, 0, sizeof(*mgp));
 	mgp->dev = netdev;


