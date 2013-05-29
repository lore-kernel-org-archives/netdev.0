From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] ibm-ethernet: delete stale MCA and duplicate PSERIES dependency
Date: Wed, 29 May 2013 10:13:54 -0400
Message-ID: <1369836834-9941-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59547 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759591Ab3E2OOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 10:14:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCA support has been removed but this dependency escaped removal.
Also, there is a duplicate PPC_PSERIES dependency that appeared
when the ethernet drivers were separated into vendor/model
specific directories, so we remove that here as well.

Reported-by: Robert de Rooy <robert.de.rooy@gmail.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/ibm/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
index 6529d31..563a1ac 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -5,8 +5,7 @@
 config NET_VENDOR_IBM
 	bool "IBM devices"
 	default y
-	depends on MCA || PPC_PSERIES || PPC_PSERIES || PPC_DCR || \
-		   (IBMEBUS && SPARSEMEM)
+	depends on PPC_PSERIES || PPC_DCR || (IBMEBUS && SPARSEMEM)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
-- 
1.8.1.2
