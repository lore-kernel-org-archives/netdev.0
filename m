From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 07/12] net: dsa: b53: Define EEE register page
Date: Mon, 18 Sep 2017 14:41:23 -0700
Message-ID: <20170918214128.27896-8-f.fainelli@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34556 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbdIRVl7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:41:59 -0400
Received: by mail-wr0-f196.google.com with SMTP id k20so1142220wre.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:41:59 -0700 (PDT)
In-Reply-To: <20170918214128.27896-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for migrating the EEE code from bcm_sf2 to b53, define the full
EEE register page and offsets within that page.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_regs.h | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index 5e8b8e31fee8..2a9f421680aa 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -50,6 +50,9 @@
 /* Jumbo Frame Registers */
 #define B53_JUMBO_PAGE			0x40
 
+/* EEE Control Registers Page */
+#define B53_EEE_PAGE			0x92
+
 /* CFP Configuration Registers Page */
 #define B53_CFP_PAGE			0xa1
 
@@ -472,6 +475,44 @@
 #define   JMS_MAX_SIZE			9724
 
 /*************************************************************************
+ * EEE Configuration Page Registers
+ *************************************************************************/
+
+/* EEE Enable control register (16 bit) */
+#define B53_EEE_EN_CTRL			0x00
+
+/* EEE LPI assert status register (16 bit) */
+#define B53_EEE_LPI_ASSERT_STS		0x02
+
+/* EEE LPI indicate status register (16 bit) */
+#define B53_EEE_LPI_INDICATE		0x4
+
+/* EEE Receiving idle symbols status register (16 bit) */
+#define B53_EEE_RX_IDLE_SYM_STS		0x6
+
+/* EEE Pipeline timer register (32 bit) */
+#define B53_EEE_PIP_TIMER		0xC
+
+/* EEE Sleep timer Gig register (32 bit) */
+#define B53_EEE_SLEEP_TIMER_GIG(i)	(0x10 + 4 * (i))
+
+/* EEE Sleep timer FE register (32 bit) */
+#define B53_EEE_SLEEP_TIMER_FE(i)	(0x34 + 4 * (i))
+
+/* EEE Minimum LP timer Gig register (32 bit) */
+#define B53_EEE_MIN_LP_TIMER_GIG(i)	(0x58 + 4 * (i))
+
+/* EEE Minimum LP timer FE register (32 bit) */
+#define B53_EEE_MIN_LP_TIMER_FE(i)	(0x7c + 4 * (i))
+
+/* EEE Wake timer Gig register (16 bit) */
+#define B53_EEE_WAKE_TIMER_GIG(i)	(0xa0 + 2 * (i))
+
+/* EEE Wake timer FE register (16 bit) */
+#define B53_EEE_WAKE_TIMER_FE(i)	(0xb2 + 2 * (i))
+
+
+/*************************************************************************
  * CFP Configuration Page Registers
  *************************************************************************/
 
-- 
2.9.3
