From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [patch resend build-breakage] make bnx2x select ZLIB_INFLATE
Date: Wed, 05 Dec 2007 16:12:39 +0200
Message-ID: <1196863959.5204.25.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"Lee Schermerhorn" <Lee.Schermerhorn@hp.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1877 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbXLEOM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 09:12:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x module depends on the zlib_inflate functions.  The
build will fail if ZLIB_INFLATE has not been selected manually
or by building another module that automatically selects it.

Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
and others.  This seems to fix it.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5bafb30..b9d7f5b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2594,6 +2594,7 @@ config TEHUTI
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
+	select ZLIB_INFLATE
 	help
 	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
-- 
1.5.3.2




