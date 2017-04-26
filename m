From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 4/9] drivers: net: xgene: Remove unused macros
Date: Wed, 26 Apr 2017 16:38:50 -0700
Message-ID: <1493249935-30759-5-git-send-email-isubramanian@apm.com>
References: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35115 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032764AbdDZXgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:38 -0400
Received: by mail-pf0-f170.google.com with SMTP id v14so8273357pfd.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:38 -0700 (PDT)
In-Reply-To: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
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
index c6b5bbd..5a9f9d5 100644
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
