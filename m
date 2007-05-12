From: olof@lixom.net
Subject: [patch 1/4] pasemi_mac: Fix register defines
Date: Sat, 12 May 2007 14:57:27 -0500
Message-ID: <20070512195727.GB15137@lixom.net>
References: <20070512193929.193104000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46365 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757061AbXELTyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 15:54:45 -0400
Content-Disposition: inline; filename=pasemi_mac-header-fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some shift values were obviously wrong. Fix them to correspond with
the masks.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -341,7 +341,7 @@ enum {
 						 PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
 #define PAS_IOB_DMA_RXCH_RESET(i)	(0x1500 + (i)*4)
 #define    PAS_IOB_DMA_RXCH_RESET_PCNT_M	0xffff0000
-#define    PAS_IOB_DMA_RXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_RXCH_RESET_PCNT_S	16
 #define    PAS_IOB_DMA_RXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_RXCH_RESET_PCNT_S) & \
 						 PAS_IOB_DMA_RXCH_RESET_PCNT_M)
 #define    PAS_IOB_DMA_RXCH_RESET_PCNTRST	0x00000020
@@ -352,7 +352,7 @@ enum {
 #define    PAS_IOB_DMA_RXCH_RESET_PINTC		0x00000001
 #define PAS_IOB_DMA_TXCH_RESET(i)	(0x1600 + (i)*4)
 #define    PAS_IOB_DMA_TXCH_RESET_PCNT_M	0xffff0000
-#define    PAS_IOB_DMA_TXCH_RESET_PCNT_S	0
+#define    PAS_IOB_DMA_TXCH_RESET_PCNT_S	16
 #define    PAS_IOB_DMA_TXCH_RESET_PCNT(x)	(((x) << PAS_IOB_DMA_TXCH_RESET_PCNT_S) & \
 						 PAS_IOB_DMA_TXCH_RESET_PCNT_M)
 #define    PAS_IOB_DMA_TXCH_RESET_PCNTRST	0x00000020

--
