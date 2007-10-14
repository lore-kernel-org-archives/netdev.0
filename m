From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] tc35815: remove redefinition of lp
Date: Sun, 14 Oct 2007 15:35:55 +0900
Message-ID: <20071014153555.6ad676d8.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo30.po.2iij.NET ([210.128.50.51]:9150 "EHLO mfo30.po.2iij.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbXJNGpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 02:45:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove redefinition of lp in tc35815.c.

drivers/net/tc35815.c: In function 'tc35815_interrupt':
drivers/net/tc35815.c:1464: error: redefinition of 'lp'
drivers/net/tc35815.c:1443: error: previous definition of 'lp' was here

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/tc35815.c generic/drivers/net/tc35815.c
--- generic-orig/drivers/net/tc35815.c	2007-10-13 20:23:24.627909000 +0900
+++ generic/drivers/net/tc35815.c	2007-10-14 15:09:16.170932750 +0900
@@ -1461,7 +1461,6 @@ static irqreturn_t tc35815_interrupt(int
 	}
 	return IRQ_NONE;
 #else
-	struct tc35815_local *lp = dev->priv;
 	int handled;
 	u32 status;
 
