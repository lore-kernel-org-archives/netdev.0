From: <netanel@amazon.com>
Subject: [PATCH net-next 07/13] net: ena: use napi_schedule_irqoff when possible
Date: Fri, 9 Jun 2017 01:01:19 +0300
Message-ID: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:31223 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdFHWC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:02:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 04aade8..424b4d7 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1264,7 +1264,7 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 {
 	struct ena_napi *ena_napi = data;
 
-	napi_schedule(&ena_napi->napi);
+	napi_schedule_irqoff(&ena_napi->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.7.4
