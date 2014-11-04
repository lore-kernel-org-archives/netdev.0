From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 11/12] amd-xgbe: Let AMD_XGBE depend on HAS_IOMEM
Date: Tue, 4 Nov 2014 16:07:41 -0600
Message-ID: <20141104220740.24738.32223.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0116.outbound.protection.outlook.com ([207.46.100.116]:37568
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751325AbaKDWXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:23:16 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe driver needs to perform ioremap calls, so add HAS_IOMEM
to its build dependency.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 8319c99..7a5e4aa 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -179,7 +179,7 @@ config SUNLANCE
 
 config AMD_XGBE
 	tristate "AMD 10GbE Ethernet driver"
-	depends on OF_NET
+	depends on OF_NET && HAS_IOMEM
 	select PHYLIB
 	select AMD_XGBE_PHY
 	select BITREVERSE
