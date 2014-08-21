From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] net:fec: buffer descriptor member variable order in IMX6
Date: Thu, 21 Aug 2014 17:21:55 +0800
Message-ID: <1408612915-8657-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1408612915-8657-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Frank Li <Frank.Li@freescale.com>
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408612915-8657-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Reference Manual, freescale IMX6 is little endian mode. Therefore
the first structure field is length, the second is status.

CC: David Miller <davem@davemloft.net>
CC: Frank Li <Frank.Li@freescale.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/ethernet/freescale/fec.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 671d080..96a5f8a 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -147,7 +147,8 @@
 /*
  *	Define the buffer descriptor structure.
  */
-#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28) || \
+			defined(CONFIG_ARCH_MX6)
 struct bufdesc {
 	unsigned short cbd_datlen;	/* Data length */
 	unsigned short cbd_sc;	/* Control and status info */
-- 
1.9.1
