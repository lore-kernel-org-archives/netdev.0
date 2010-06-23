From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] net: add dependency on fw class module
Date: Tue, 22 Jun 2010 23:54:35 -0700
Message-ID: <1277276075-29322-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50893 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751493Ab0FWGyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jun 2010 02:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

netxen_nic and qlcnic driver depends on firmware_class module.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fe113d0..71e6f8f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2755,6 +2755,7 @@ config MYRI10GE_DCA
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
 	depends on PCI
+	select FW_LOADER
 	help
 	  This enables the support for NetXen's Gigabit Ethernet card.
 
@@ -2820,6 +2821,7 @@ config BNX2X
 config QLCNIC
 	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
 	depends on PCI
+	select FW_LOADER
 	help
 	  This driver supports QLogic QLE8240 and QLE8242 Converged Ethernet
 	  devices.
-- 
1.6.0.2

