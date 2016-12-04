From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 17/20] net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
Date: Sun,  4 Dec 2016 15:19:35 +0200
Message-ID: <1480857578-5065-18-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We intend to use those fields in the future.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index 35ae511..92bba08 100644
--- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
@@ -627,6 +627,12 @@ enum ena_admin_flow_hash_proto {
 
 	ENA_ADMIN_RSS_NOT_IP	= 7,
 
+	/* TCPv6 with extension header */
+	ENA_ADMIN_RSS_TCP6_EX	= 8,
+
+	/* IPv6 with extension header */
+	ENA_ADMIN_RSS_IP6_EX	= 9,
+
 	ENA_ADMIN_RSS_PROTO_NUM	= 16,
 };
 
-- 
2.7.4
