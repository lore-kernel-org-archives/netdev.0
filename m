From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Zap changelog from source code
Date: Thu, 15 Mar 2007 00:10:37 +0900 (JST)
Message-ID: <20070315.001037.25910308.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:58884 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161333AbXCNPKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 11:10:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index eed78b5..755fdd4 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -20,45 +20,6 @@
  *
  * (C) Copyright TOSHIBA CORPORATION 2004-2005
  * All Rights Reserved.
- *
- *  Revision History:
- *	1.13	64-bit proof.
- *	1.14	Do not round-up transmit length.
- *	1.15	Define TC35815_DMA_SYNC_ONDEMAND, cleanup.
- *	1.16	Fix free_page bug introduced in 1.15
- *	1.17	Add mii/ethtool ioctl support.
- *		Remove workaround for early TX4938.  Cleanup.
- *	1.20	Kernel 2.6.
- *	1.21	Fix receive packet length (omit CRC).
- *		Call netif_carrier_on/netif_carrier_off.
- *		Add kernel/module options (speed, duplex, doforce).
- *		Do not try "force link mode" by default.
- *		Reconfigure CAM on restarting.
- *		Reset PHY on restarting.
- *		Add workaround for 100MHalf HUB.
- *	1.22	Minor fix.
- *	1.23	Minor cleanup.
- *	1.24	Remove tc35815_setup since new stype option
- *		("tc35815.speed=10", etc.) can be used for 2.6 kernel.
- *	1.25	TX4939 support.
- *	1.26	Minor cleanup.
- *	1.27	Move TX4939 PCFG.SPEEDn control code out from this driver.
- *		Cleanup init_dev_addr. (NETDEV_REGISTER event notifier
- *		can overwrite dev_addr)
- *		support ETHTOOL_GPERMADDR.
- *	1.28	Minor cleanup.
- *	1.29	support netpoll.
- *	1.30	Minor cleanup.
- *	1.31	NAPI support. (disabled by default)
- *		Use DMA_RxAlign_2 if possible.
- *		Do not use PackedBuffer.
- *		Cleanup.
- *	1.32	Fix free buffer management on non-PackedBuffer mode.
- *	1.33	Fix netpoll build.
- *	1.34	Fix netpoll locking.  "BH rule" for NAPI is not enough with
- *		netpoll, hard_start_xmit might be called from irq context.
- *		PM support.
- *	1.35	Fix an usage of streaming DMA API.
  */
 
 #ifdef TC35815_NAPI
