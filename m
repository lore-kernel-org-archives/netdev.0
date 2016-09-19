From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/10] bnxt_en: Pad TX packets below 52 bytes.
Date: Mon, 19 Sep 2016 03:58:07 -0400
Message-ID: <1474271889-8229-9-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33335 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932428AbcISH6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:32 -0400
Received: by mail-pf0-f174.google.com with SMTP id 21so37610501pfy.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:32 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware has a limitation that it won't pass host to BMC loopback
packets below 52-bytes.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 41033d0..51b164a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -413,7 +413,7 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_RX_PAGE_SIZE (1 << BNXT_RX_PAGE_SHIFT)
 
-#define BNXT_MIN_PKT_SIZE	45
+#define BNXT_MIN_PKT_SIZE	52
 
 #define BNXT_NUM_TESTS(bp)	0
 
-- 
1.8.3.1
