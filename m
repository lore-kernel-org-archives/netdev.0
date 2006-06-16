From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 6/6] b44: update b44 Kconfig entry
Date: Fri, 16 Jun 2006 12:19:34 -0700
Message-ID: <1150485574.8716.55.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:49414 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751475AbWFPTUM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 15:20:12 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Deleted "EXPERIMENTAL" from b44 entry in Kconfig.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bdaaad8..4e57785 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1359,8 +1359,8 @@ config APRICOT
 	  called apricot.

 config B44
-	tristate "Broadcom 4400 ethernet support (EXPERIMENTAL)"
-	depends on NET_PCI && PCI && EXPERIMENTAL
+	tristate "Broadcom 4400 ethernet support"
+	depends on NET_PCI && PCI
 	select MII
 	help
 	  If you have a network (Ethernet) controller of this type, say Y and


