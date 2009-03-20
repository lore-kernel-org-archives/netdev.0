From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/5] sfc: Remove unused private PCI register definitions
Date: Fri, 20 Mar 2009 23:26:55 +0000
Message-ID: <1237591615.3217.10.camel@achroite>
References: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:43835 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763234AbZCTX07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:26:59 -0400
In-Reply-To: <1237591540.3217.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 92ea614..f42fc60 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -155,13 +155,6 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Dummy SRAM size code */
 #define SRM_NB_BSZ_ONCHIP_ONLY (-1)
 
-/* Be nice if these (or equiv.) were in linux/pci_regs.h, but they're not. */
-#define PCI_EXP_DEVCAP_PWR_VAL_LBN	18
-#define PCI_EXP_DEVCAP_PWR_SCL_LBN	26
-#define PCI_EXP_DEVCTL_PAYLOAD_LBN	5
-#define PCI_EXP_LNKSTA_LNK_WID		0x3f0
-#define PCI_EXP_LNKSTA_LNK_WID_LBN	4
-
 #define FALCON_IS_DUAL_FUNC(efx)		\
 	(falcon_rev(efx) < FALCON_REV_B0)
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

