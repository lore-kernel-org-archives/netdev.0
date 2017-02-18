From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v1] RDS: keep data type consistent in the user visible header
Date: Fri, 17 Feb 2017 19:21:21 -0800
Message-ID: <1487388081-6559-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48047 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdBRDVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 22:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds.h is exported to /usr/include/rds.h,  so u8, u64 leads to
errors like below.

/usr/include/linux/rds.h:197: error: expected specifier-qualifier-list before 'u8'
/usr/include/linux/rds.h:202: error: expected specifier-qualifier-list before 'u8'

Fix it by following same types as rest of the user header.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
V1: Fixed the email id typo

 include/uapi/linux/rds.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 3833113..a9e4c02 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -194,14 +194,14 @@ enum rds_message_rxpath_latency {
 };
 
 struct rds_rx_trace_so {
-	u8 rx_traces;
-	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	uint8_t rx_traces;
+	uint8_t rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
 };
 
 struct rds_cmsg_rx_trace {
-	u8 rx_traces;
-	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
-	u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	uint8_t rx_traces;
+	uint8_t rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	uint64_t rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
 };
 
 /*
-- 
1.9.1
