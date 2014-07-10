From: varkabhadram@gmail.com
Subject: [PATCH net 1/7] net: cpmac: remove space in macro defination
Date: Thu, 10 Jul 2014 10:17:54 +0530
Message-ID: <1404967680-13206-2-git-send-email-varkabhadram@gmail.com>
References: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51297 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaGJEtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 00:49:24 -0400
Received: by mail-pa0-f53.google.com with SMTP id ey11so10261849pad.26
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 21:49:24 -0700 (PDT)
In-Reply-To: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch fix the space after '#' in macro defination

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |   82 +++++++++++++++++++--------------------
 1 file changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 7399a52..61eb691 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -67,42 +67,42 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 #define CPMAC_RX_CONTROL		0x0014
 #define CPMAC_RX_TEARDOWN		0x0018
 #define CPMAC_MBP			0x0100
-# define MBP_RXPASSCRC			0x40000000
-# define MBP_RXQOS			0x20000000
-# define MBP_RXNOCHAIN			0x10000000
-# define MBP_RXCMF			0x01000000
-# define MBP_RXSHORT			0x00800000
-# define MBP_RXCEF			0x00400000
-# define MBP_RXPROMISC			0x00200000
-# define MBP_PROMISCCHAN(channel)	(((channel) & 0x7) << 16)
-# define MBP_RXBCAST			0x00002000
-# define MBP_BCASTCHAN(channel)		(((channel) & 0x7) << 8)
-# define MBP_RXMCAST			0x00000020
-# define MBP_MCASTCHAN(channel)		((channel) & 0x7)
+#define MBP_RXPASSCRC			0x40000000
+#define MBP_RXQOS			0x20000000
+#define MBP_RXNOCHAIN			0x10000000
+#define MBP_RXCMF			0x01000000
+#define MBP_RXSHORT			0x00800000
+#define MBP_RXCEF			0x00400000
+#define MBP_RXPROMISC			0x00200000
+#define MBP_PROMISCCHAN(channel)	(((channel) & 0x7) << 16)
+#define MBP_RXBCAST			0x00002000
+#define MBP_BCASTCHAN(channel)		(((channel) & 0x7) << 8)
+#define MBP_RXMCAST			0x00000020
+#define MBP_MCASTCHAN(channel)		((channel) & 0x7)
 #define CPMAC_UNICAST_ENABLE		0x0104
 #define CPMAC_UNICAST_CLEAR		0x0108
 #define CPMAC_MAX_LENGTH		0x010c
 #define CPMAC_BUFFER_OFFSET		0x0110
 #define CPMAC_MAC_CONTROL		0x0160
-# define MAC_TXPTYPE			0x00000200
-# define MAC_TXPACE			0x00000040
-# define MAC_MII			0x00000020
-# define MAC_TXFLOW			0x00000010
-# define MAC_RXFLOW			0x00000008
-# define MAC_MTEST			0x00000004
-# define MAC_LOOPBACK			0x00000002
-# define MAC_FDX			0x00000001
+#define MAC_TXPTYPE			0x00000200
+#define MAC_TXPACE			0x00000040
+#define MAC_MII				0x00000020
+#define MAC_TXFLOW			0x00000010
+#define MAC_RXFLOW			0x00000008
+#define MAC_MTEST			0x00000004
+#define MAC_LOOPBACK			0x00000002
+#define MAC_FDX				0x00000001
 #define CPMAC_MAC_STATUS		0x0164
-# define MAC_STATUS_QOS			0x00000004
-# define MAC_STATUS_RXFLOW		0x00000002
-# define MAC_STATUS_TXFLOW		0x00000001
+#define MAC_STATUS_QOS			0x00000004
+#define MAC_STATUS_RXFLOW		0x00000002
+#define MAC_STATUS_TXFLOW		0x00000001
 #define CPMAC_TX_INT_ENABLE		0x0178
 #define CPMAC_TX_INT_CLEAR		0x017c
 #define CPMAC_MAC_INT_VECTOR		0x0180
-# define MAC_INT_STATUS			0x00080000
-# define MAC_INT_HOST			0x00040000
-# define MAC_INT_RX			0x00020000
-# define MAC_INT_TX			0x00010000
+#define MAC_INT_STATUS			0x00080000
+#define MAC_INT_HOST			0x00040000
+#define MAC_INT_RX			0x00020000
+#define MAC_INT_TX			0x00010000
 #define CPMAC_MAC_EOI_VECTOR		0x0184
 #define CPMAC_RX_INT_ENABLE		0x0198
 #define CPMAC_RX_INT_CLEAR		0x019c
@@ -157,24 +157,24 @@ MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 /* MDIO bus */
 #define CPMAC_MDIO_VERSION		0x0000
 #define CPMAC_MDIO_CONTROL		0x0004
-# define MDIOC_IDLE			0x80000000
-# define MDIOC_ENABLE			0x40000000
-# define MDIOC_PREAMBLE			0x00100000
-# define MDIOC_FAULT			0x00080000
-# define MDIOC_FAULTDETECT		0x00040000
-# define MDIOC_INTTEST			0x00020000
-# define MDIOC_CLKDIV(div)		((div) & 0xff)
+#define MDIOC_IDLE			0x80000000
+#define MDIOC_ENABLE			0x40000000
+#define MDIOC_PREAMBLE			0x00100000
+#define MDIOC_FAULT			0x00080000
+#define MDIOC_FAULTDETECT		0x00040000
+#define MDIOC_INTTEST			0x00020000
+#define MDIOC_CLKDIV(div)		((div) & 0xff)
 #define CPMAC_MDIO_ALIVE		0x0008
 #define CPMAC_MDIO_LINK			0x000c
 #define CPMAC_MDIO_ACCESS(channel)	(0x0080 + (channel) * 8)
-# define MDIO_BUSY			0x80000000
-# define MDIO_WRITE			0x40000000
-# define MDIO_REG(reg)			(((reg) & 0x1f) << 21)
-# define MDIO_PHY(phy)			(((phy) & 0x1f) << 16)
-# define MDIO_DATA(data)		((data) & 0xffff)
+#define MDIO_BUSY			0x80000000
+#define MDIO_WRITE			0x40000000
+#define MDIO_REG(reg)			(((reg) & 0x1f) << 21)
+#define MDIO_PHY(phy)			(((phy) & 0x1f) << 16)
+#define MDIO_DATA(data)			((data) & 0xffff)
 #define CPMAC_MDIO_PHYSEL(channel)	(0x0084 + (channel) * 8)
-# define PHYSEL_LINKSEL			0x00000040
-# define PHYSEL_LINKINT			0x00000020
+#define PHYSEL_LINKSEL			0x00000040
+#define PHYSEL_LINKINT			0x00000020
 
 struct cpmac_desc {
 	u32 hw_next;
-- 
1.7.9.5
