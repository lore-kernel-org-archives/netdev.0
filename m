From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 4/4][RFC] ehea: Kconfig
Date: Mon, 30 Jul 2007 17:24:55 +0200
Message-ID: <200707301724.55804.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:50534 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936307AbXG3PyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 11:54:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig changes for LRO

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f8a602c..fec4004 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2399,6 +2399,7 @@ config CHELSIO_T3
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS
+	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
 
-- 
1.5.2

