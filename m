From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/1] net/cadence: enable by default NET_ATMEL
Date: Tue, 15 Nov 2011 20:36:30 +0100
Message-ID: <1321385790-15056-1-git-send-email-plagnioj@jcrosoft.com>
Cc: netdev@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

so the defconfig of the atmel continue to have the support of the network
as before

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Hi David,

	can we have this for the 3.2 so the atmel continue to work as before

Best Regards,
J.
 drivers/net/ethernet/cadence/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 98849a1..b48378a 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -7,6 +7,7 @@ config HAVE_NET_MACB
 
 config NET_ATMEL
 	bool "Atmel devices"
+	default y
 	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
-- 
1.7.7
