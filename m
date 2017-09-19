From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 07/12] net: dsa: b53: Define EEE register page
Date: Tue, 19 Sep 2017 10:46:49 -0700
Message-ID: <20170919174654.2122-8-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33498 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751815AbdISRrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id m127so325688wmm.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:20 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for migrating the EEE code from bcm_sf2 to b53, define the full
EEE register page and offsets within that page.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
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
