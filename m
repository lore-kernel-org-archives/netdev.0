From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 7/7] qed: Increase per queue max coalesce value.
Date: Fri, 30 Jun 2017 02:39:46 -0700
Message-ID: <20170630093946.18497-8-manish.chopra@cavium.com>
References: <20170630093946.18497-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <rahul.verma@cavium.com>, <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0050.outbound.protection.outlook.com ([104.47.34.50]:19386
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751672AbdF3JkB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 05:40:01 -0400
In-Reply-To: <20170630093946.18497-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Verma <rahul.verma@cavium.com>

Maximum coalesce per Rx/Tx queue is extended from
255 to 511.

Signed-off-by: Rahul Verma <rahul.verma@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 include/linux/qed/qed_if.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 2b4720b..cc646ca 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -184,7 +184,7 @@ enum qed_led_mode {
 
 #define DIRECT_REG_RD(reg_addr) readl((void __iomem *)(reg_addr))
 
-#define QED_COALESCE_MAX 0xFF
+#define QED_COALESCE_MAX 0x1FF
 #define QED_DEFAULT_RX_USECS 12
 #define QED_DEFAULT_TX_USECS 48
 
-- 
2.7.2
