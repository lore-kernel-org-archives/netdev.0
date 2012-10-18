From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 01/14] net/macb: add AT91RM9200 specific registers and bits to header
Date: Thu, 18 Oct 2012 23:01:06 +0200
Message-ID: <1350594079-4337-2-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:52354 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261Ab2JRVBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:34 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so6136401lag.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:33 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 335e288..0e5d55b 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -14,6 +14,8 @@
 #define MACB_NCR				0x0000
 #define MACB_NCFGR				0x0004
 #define MACB_NSR				0x0008
+#define MACB_TAR				0x000c /* AT91RM9200 only */
+#define MACB_TCR				0x0010 /* AT91RM9200 only */
 #define MACB_TSR				0x0014
 #define MACB_RBQP				0x0018
 #define MACB_TBQP				0x001c
@@ -133,6 +135,8 @@
 #define MACB_RTY_SIZE				1
 #define MACB_PAE_OFFSET				13
 #define MACB_PAE_SIZE				1
+#define MACB_RM9200_RMII_OFFSET			13 /* AT91RM9200 only */
+#define MACB_RM9200_RMII_SIZE			1  /* AT91RM9200 only */
 #define MACB_RBOF_OFFSET			14
 #define MACB_RBOF_SIZE				2
 #define MACB_RLCE_OFFSET			16
@@ -178,6 +182,8 @@
 #define MACB_TGO_SIZE				1
 #define MACB_BEX_OFFSET				4
 #define MACB_BEX_SIZE				1
+#define MACB_RM9200_BNQ_OFFSET			4 /* AT91RM9200 only */
+#define MACB_RM9200_BNQ_SIZE			1 /* AT91RM9200 only */
 #define MACB_COMP_OFFSET			5
 #define MACB_COMP_SIZE				1
 #define MACB_UND_OFFSET				6
-- 
1.7.12.3
