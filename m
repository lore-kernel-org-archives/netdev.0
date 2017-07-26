From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH v2 net-next 7/7] qed: enhanced per queue max coalesce value.
Date: Wed, 26 Jul 2017 06:07:15 -0700
Message-ID: <20170726130715.12976-8-manish.chopra@cavium.com>
References: <20170726130715.12976-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <rahul.verma@cavium.com>, <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0045.outbound.protection.outlook.com ([104.47.41.45]:14768
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751068AbdGZNHb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 09:07:31 -0400
In-Reply-To: <20170726130715.12976-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Verma <rahul.verma@cavium.com>

Maximum coalesce per Rx/Tx queue is extended from
255 to 511.

Signed-off-by: Rahul Verma <rahul.verma@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 include/linux/qed/qed_if.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
1.7.1
