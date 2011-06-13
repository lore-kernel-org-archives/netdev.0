From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Fix EEE debounce timer values
Date: Mon, 13 Jun 2011 16:38:59 -0700
Message-ID: <1308008342-21030-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1278 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755320Ab1FMXiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the EEE debounce timer values.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index fc33566..54441a3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1118,10 +1118,10 @@
 #define  TG3_CPMU_EEEMD_EEE_ENABLE	 0x00100000
 #define TG3_CPMU_EEE_DBTMR1		0x000036b4
 #define  TG3_CPMU_DBTMR1_PCIEXIT_2047US	 0x07ff0000
-#define  TG3_CPMU_DBTMR1_LNKIDLE_2047US	 0x000070ff
+#define  TG3_CPMU_DBTMR1_LNKIDLE_2047US	 0x000007ff
 #define TG3_CPMU_EEE_DBTMR2		0x000036b8
 #define  TG3_CPMU_DBTMR2_APE_TX_2047US	 0x07ff0000
-#define  TG3_CPMU_DBTMR2_TXIDXEQ_2047US	 0x000070ff
+#define  TG3_CPMU_DBTMR2_TXIDXEQ_2047US	 0x000007ff
 #define TG3_CPMU_EEE_LNKIDL_CTRL	0x000036bc
 #define  TG3_CPMU_EEE_LNKIDL_PCIE_NL0	 0x01000000
 #define  TG3_CPMU_EEE_LNKIDL_UART_IDL	 0x00000004
-- 
1.7.3.4


