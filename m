From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] drivers: net: phy: mdio-xgene: Add hardware dependency
Date: Thu, 8 Sep 2016 16:25:15 +0200
Message-ID: <20160908162515.1a69cf67@endymion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Iyappan Subramanian <isubramanian@apm.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38450 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754676AbcIHOZT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 10:25:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio-xgene driver is only useful on X-Gene SoC.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Iyappan Subramanian <isubramanian@apm.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-4.8-rc5.orig/drivers/net/phy/Kconfig	2016-09-04 23:31:46.000000000 +0200
+++ linux-4.8-rc5/drivers/net/phy/Kconfig	2016-09-08 15:05:08.815824055 +0200
@@ -303,6 +303,7 @@ config MDIO_HISI_FEMAC
 
 config MDIO_XGENE
 	tristate "APM X-Gene SoC MDIO bus controller"
+	depends on ARCH_XGENE || COMPILE_TEST
 	help
 	  This module provides a driver for the MDIO busses found in the
 	  APM X-Gene SoC's.


-- 
Jean Delvare
SUSE L3 Support
