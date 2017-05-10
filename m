From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 06/12] drivers: net: xgene: Remove unused macros
Date: Wed, 10 May 2017 13:45:04 -0700
Message-ID: <1494449110-23785-7-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33016 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753878AbdEJUm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:28 -0400
Received: by mail-io0-f177.google.com with SMTP id p24so9504300ioi.0
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:27 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch cleans up unused macros to improve readability.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 3ce349f..ed51005 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -217,12 +217,6 @@ enum xgene_enet_rm {
 #define FULL_DUPLEX2			BIT(0)
 #define PAD_CRC				BIT(2)
 #define LENGTH_CHK			BIT(4)
-#define SCAN_AUTO_INCR			BIT(5)
-#define TBYT_ADDR			0x38
-#define TPKT_ADDR			0x39
-#define TDRP_ADDR			0x45
-#define TFCS_ADDR			0x47
-#define TUND_ADDR			0x4a
 
 #define TSO_IPPROTO_TCP			1
 
-- 
1.9.1
