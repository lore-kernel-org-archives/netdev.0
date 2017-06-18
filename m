From: <netanel@amazon.com>
Subject: [PATCH net-next 12/13] net: ena: change validate_tx_req_id() to be inline function
Date: Sun, 18 Jun 2017 14:28:17 +0300
Message-ID: <1497785298-13468-13-git-send-email-netanel@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:9210 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753141AbdFRLax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 07:30:53 -0400
In-Reply-To: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

for optimization purpose, change validate_tx_req_id() to be
inline function.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 4540cd3d9f5f..da14b78cc87c 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -698,7 +698,7 @@ static void ena_destroy_all_io_queues(struct ena_adapter *adapter)
 	ena_destroy_all_rx_queues(adapter);
 }
 
-static int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)
+static inline int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)
 {
 	struct ena_tx_buffer *tx_info = NULL;
 
-- 
2.7.4
