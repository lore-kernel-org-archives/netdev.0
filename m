From: Dave Jiang <djiang@mvista.com>
Subject: [PATCH] gianfar needs crc32 lib dependency
Date: Thu, 12 Apr 2007 10:57:06 -0700
Message-ID: <20070412175706.GA12664@blade.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: galak@kernel.crashing.org, afleming@freescale.com,
	sshtylyov@ru.mvista.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:51971 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030624AbXDLRy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 13:54:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Gianfar needs crc32 to be selected to compile. 

Signed-off-by: Dave Jiang <djiang@mvista.com>

--
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
--

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8aa8dd0..2516e0b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2274,6 +2274,7 @@ config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx || PPC_86xx
 	select PHYLIB
+	select CRC32
 	help
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
 	  and MPC86xx family of chips, and the FEC on the 8540.
