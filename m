From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] tg3: Add phylib dependency to kconfig
Date: Tue, 27 May 2008 11:07:42 -0700
Message-ID: <20080527180742.GB31979@localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1769 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbYE0SEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 14:04:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PHYLIB dependency to kconfig.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f6cc8a..78cc949 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2228,6 +2228,7 @@ config VIA_VELOCITY
 config TIGON3
 	tristate "Broadcom Tigon3 support"
 	depends on PCI
+	select PHYLIB
 	help
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 


