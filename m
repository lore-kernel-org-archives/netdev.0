From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: xgene_enet: Set hardware dependency
Date: Wed, 6 May 2015 09:14:34 +0200
Message-ID: <20150506091434.6762db64@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58782 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbbEFHOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 03:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xgene_enet driver is only useful on X-Gene SoC.
    
Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Iyappan Subramanian <isubramanian@apm.com>
Cc: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-4.1-rc2.orig/drivers/net/ethernet/apm/xgene/Kconfig	2015-04-27 02:59:10.000000000 +0200
+++ linux-4.1-rc2/drivers/net/ethernet/apm/xgene/Kconfig	2015-05-06 09:09:49.084111852 +0200
@@ -1,6 +1,7 @@
 config NET_XGENE
 	tristate "APM X-Gene SoC Ethernet Driver"
 	depends on HAS_DMA
+	depends on ARCH_XGENE || COMPILE_TEST
 	select PHYLIB
 	help
 	  This is the Ethernet driver for the on-chip ethernet interface on the


-- 
Jean Delvare
SUSE L3 Support
