From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH -next] net: calxeda xgmac ethernet driver add missing HAS_IOMEM dependency
Date: Tue, 27 Dec 2011 15:07:05 +0100
Message-ID: <1324994825-4197-1-git-send-email-heiko.carstens@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rob Herring <rob.herring@calxeda.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:35601 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab1L0OHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 09:07:12 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Dec 2011 14:07:10 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix allyesconfig build on architectures without IOMEM:

drivers/net/ethernet/calxeda/xgmac.c:1800:2:
  error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/Kconfig b/drivers/net/ethernet/calxeda/Kconfig
index a52e725..aba435c 100644
--- a/drivers/net/ethernet/calxeda/Kconfig
+++ b/drivers/net/ethernet/calxeda/Kconfig
@@ -1,6 +1,6 @@
 config NET_CALXEDA_XGMAC
 	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
-
+	depends on HAS_IOMEM
 	select CRC32
 	help
 	  This is the driver for the XGMAC Ethernet IP block found on Calxeda
-- 
1.7.7.3
