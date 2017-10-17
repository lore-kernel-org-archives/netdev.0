From: <netanel@amazon.com>
Subject: [PATCH net-next 5/6] net: ena: add new admin define for future support of IPv6 RSS
Date: Tue, 17 Oct 2017 07:34:00 +0000
Message-ID: <1508225641-106366-6-git-send-email-netanel@amazon.com>
References: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:48655 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933111AbdJQHer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:47 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index 305dc1996b4e..4532e574ebcd 100644
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
1.8.3.1
