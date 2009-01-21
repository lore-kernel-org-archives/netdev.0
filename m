From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 4/9] bnx2x: annotate struct eth_fast_path_rx_cqe
Date: Tue, 20 Jan 2009 21:50:48 -0800
Message-ID: <1232517048.9701.22.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:24781 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbZAUFuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:55 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192261wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always treated as little-endian values, annotate as such.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_hsi.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index b62d45e..ba066b7 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -2212,12 +2212,12 @@ struct eth_fast_path_rx_cqe {
 #define ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG_SHIFT 7
 	u8 placement_offset;
 	u8 queue_index;
-	u32 rss_hash_result;
-	u16 vlan_tag;
-	u16 pkt_len;
-	u16 len_on_bd;
+	__le32 rss_hash_result;
+	__le16 vlan_tag;
+	__le16 pkt_len;
+	__le16 len_on_bd;
 	struct parsing_flags pars_flags;
-	u16 sgl[8];
+	__le16 sgl[8];
 };
 

-- 
1.6.1.249.g455e5


