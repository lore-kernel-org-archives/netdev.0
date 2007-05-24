From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] remove unnecessary dependency on VIA velocity config
Date: Thu, 24 May 2007 16:12:27 +0900
Message-ID: <20070524161227.63f59798.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo30.po.2iij.NET ([210.128.50.51]:14689 "EHLO
	mfo30.po.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbXEXHsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 03:48:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch has removed unnecessary dependency on VIA velocity config.

Yoichi

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/Kconfig generic/drivers/net/Kconfig
--- generic-orig/drivers/net/Kconfig	2007-05-24 15:25:09.222409250 +0900
+++ generic/drivers/net/Kconfig	2007-05-24 15:23:41.916953000 +0900
@@ -2218,7 +2218,7 @@ config SK98LIN
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on NET_PCI && PCI
+	depends on PCI
 	select CRC32
 	select CRC_CCITT
 	select MII
