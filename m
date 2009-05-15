From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/3] mdio: Add 10GBASE-T SNR register definition
Date: Fri, 15 May 2009 17:04:12 +0100
Message-ID: <1242403452.3262.0.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:58090 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762605AbZEOQEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 12:04:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These do not have an in-kernel user but may be useful to user-space.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/mdio.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 26b4eb3..825f1e2 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -46,6 +46,8 @@
 
 /* Media-dependent registers. */
 #define MDIO_PMA_10GBT_TXPWR	131	/* 10GBASE-T TX power control */
+#define MDIO_PMA_10GBT_SNR	133	/* 10GBASE-T SNR margin, lane A.
+					 * Lanes B-D are numbered 134-136. */
 #define MDIO_PMA_10GBR_FECABLE	170	/* 10GBASE-R FEC ability */
 #define MDIO_PCS_10GBX_STAT1	24	/* 10GBASE-X PCS status 1 */
 #define MDIO_PCS_10GBRT_STAT1	32	/* 10GBASE-R/-T PCS status 1 */
@@ -188,6 +190,11 @@
 /* PMA 10GBASE-T TX power register. */
 #define MDIO_PMA_10GBT_TXPWR_SHORT	0x0001	/* Short-reach mode */
 
+/* PMA 10GBASE-T SNR registers. */
+/* Value is SNR margin in dB, clamped to range [-127, 127], plus 0x8000. */
+#define MDIO_PMA_10GBT_SNR_BIAS		0x8000
+#define MDIO_PMA_10GBT_SNR_MAX		127
+
 /* PMA 10GBASE-R FEC ability register. */
 #define MDIO_PMA_10GBR_FECABLE_ABLE	0x0001	/* FEC ability */
 #define MDIO_PMA_10GBR_FECABLE_ERRABLE	0x0002	/* FEC error indic. ability */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

