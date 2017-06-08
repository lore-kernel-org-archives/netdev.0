From: <netanel@amazon.com>
Subject: [PATCH net-next 09/13] net: ena: adding missing cast in ena_com_mem_addr_set()
Date: Fri, 9 Jun 2017 01:01:21 +0300
Message-ID: <1496959285-8632-10-git-send-email-netanel@amazon.com>
References: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6001.amazon.com ([52.95.48.154]:17903 "EHLO
        smtp-fw-6001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdFHWCW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:02:22 -0400
In-Reply-To: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index f6e1d30..8efb85e 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -100,7 +100,7 @@ static inline int ena_com_mem_addr_set(struct ena_com_dev *ena_dev,
 	}
 
 	ena_addr->mem_addr_low = (u32)addr;
-	ena_addr->mem_addr_high = (u64)addr >> 32;
+	ena_addr->mem_addr_high = (u16)((u64)addr >> 32);
 
 	return 0;
 }
-- 
2.7.4
