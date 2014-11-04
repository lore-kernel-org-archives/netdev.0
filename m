From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 12/12] amd-xgbe-phy: Let AMD_XGBE_PHY depend on
 HAS_IOMEM
Date: Tue, 4 Nov 2014 16:07:46 -0600
Message-ID: <20141104220746.24738.2861.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0136.outbound.protection.outlook.com ([207.46.100.136]:44000
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751447AbaKDWWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:22:14 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe-phy driver needs to perform ioremap calls, so add HAS_IOMEM
to its build dependency.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 75472cf7..b4b0f80 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -26,7 +26,7 @@ config AMD_PHY
 
 config AMD_XGBE_PHY
 	tristate "Driver for the AMD 10GbE (amd-xgbe) PHYs"
-	depends on OF
+	depends on OF && HAS_IOMEM
 	---help---
 	  Currently supports the AMD 10GbE PHY
 
