From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/3] mdio: Add XENPAK LASI register definitions
Date: Fri, 15 May 2009 17:05:49 +0100
Message-ID: <1242403549.3262.2.camel@achroite>
References: <1242403452.3262.0.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33968 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760409AbZEOQFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 12:05:49 -0400
In-Reply-To: <1242403452.3262.0.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These registers were originally defined for XENPAK modules, but are
also implemented by many other 10G PHYs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/mdio.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 825f1e2..5685164 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -55,6 +55,14 @@
 #define MDIO_AN_10GBT_CTRL	32	/* 10GBASE-T auto-negotiation control */
 #define MDIO_AN_10GBT_STAT	33	/* 10GBASE-T auto-negotiation status */
 
+/* LASI (Link Alarm Status Interrupt) registers, defined by XENPAK MSA. */
+#define MDIO_PMA_LASI_RXCTRL	0x9000	/* RX_ALARM control */
+#define MDIO_PMA_LASI_TXCTRL	0x9001	/* TX_ALARM control */
+#define MDIO_PMA_LASI_CTRL	0x9002	/* LASI control */
+#define MDIO_PMA_LASI_RXSTAT	0x9003	/* RX_ALARM status */
+#define MDIO_PMA_LASI_TXSTAT	0x9004	/* TX_ALARM status */
+#define MDIO_PMA_LASI_STAT	0x9005	/* LASI status */
+
 /* Control register 1. */
 /* Enable extended speed selection */
 #define MDIO_CTRL1_SPEEDSELEXT		(BMCR_SPEED1000 | BMCR_SPEED100)
@@ -218,6 +226,26 @@
 #define MDIO_AN_10GBT_STAT_MS		0x4000	/* Master/slave config */
 #define MDIO_AN_10GBT_STAT_MSFLT	0x8000	/* Master/slave config fault */
 
+/* LASI RX_ALARM control/status registers. */
+#define MDIO_PMA_LASI_RX_PHYXSLFLT	0x0001	/* PHY XS RX local fault */
+#define MDIO_PMA_LASI_RX_PCSLFLT	0x0008	/* PCS RX local fault */
+#define MDIO_PMA_LASI_RX_PMALFLT	0x0010	/* PMA/PMD RX local fault */
+#define MDIO_PMA_LASI_RX_OPTICPOWERFLT	0x0020	/* RX optical power fault */
+#define MDIO_PMA_LASI_RX_WISLFLT	0x0200	/* WIS local fault */
+
+/* LASI TX_ALARM control/status registers. */
+#define MDIO_PMA_LASI_TX_PHYXSLFLT	0x0001	/* PHY XS TX local fault */
+#define MDIO_PMA_LASI_TX_PCSLFLT	0x0008	/* PCS TX local fault */
+#define MDIO_PMA_LASI_TX_PMALFLT	0x0010	/* PMA/PMD TX local fault */
+#define MDIO_PMA_LASI_TX_LASERPOWERFLT	0x0080	/* Laser output power fault */
+#define MDIO_PMA_LASI_TX_LASERTEMPFLT	0x0100	/* Laser temperature fault */
+#define MDIO_PMA_LASI_TX_LASERBICURRFLT	0x0200	/* Laser bias current fault */
+
+/* LASI control/status registers. */
+#define MDIO_PMA_LASI_LSALARM		0x0001	/* LS_ALARM enable/status */
+#define MDIO_PMA_LASI_TXALARM		0x0002	/* TX_ALARM enable/status */
+#define MDIO_PMA_LASI_RXALARM		0x0004	/* RX_ALARM enable/status */
+
 /* Mapping between MDIO PRTAD/DEVAD and mii_ioctl_data::phy_id */
 
 #define MDIO_PHY_ID_C45			0x8000

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

