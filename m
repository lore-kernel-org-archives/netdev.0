From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 14/18] net/ena: add IPv6 extended protocols to ena_admin_flow_hash_proto
Date: Sun, 20 Nov 2016 10:45:43 +0200
Message-ID: <1479631547-29354-15-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:36410 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753242AbcKTIxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:53:07 -0500
Received: by mail-wj0-f181.google.com with SMTP id qp4so14058058wjc.3
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:53:07 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
1.9.1
