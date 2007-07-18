From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] fix wrong argument of tc35815_read_plat_dev_addr()
Date: Wed, 18 Jul 2007 11:13:42 +0900
Message-ID: <20070718111342.0388a43b.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo32.po.2iij.NET ([210.128.50.15]:7879 "EHLO mfo32.po.2iij.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546AbXGRCS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 22:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix wrong argument of tc35815_read_plat_dev_addr()

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/tc35815.c generic/drivers/net/tc35815.c
--- generic-orig/drivers/net/tc35815.c	2007-07-18 10:45:56.542655750 +0900
+++ generic/drivers/net/tc35815.c	2007-07-18 10:41:42.230762250 +0900
@@ -626,7 +626,7 @@ static int __devinit tc35815_read_plat_d
 	return -ENODEV;
 }
 #else
-static int __devinit tc35815_read_plat_dev_addr(struct device *dev)
+static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 {
 	return -ENODEV;
 }
