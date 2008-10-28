From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/2] infiniband: remove IPOIB_GID_RAW_ARG, IPOIB_GID_ARG,
 IPOIB_GID_FMT
Date: Tue, 28 Oct 2008 15:25:04 -0700
Message-ID: <1225232704.11483.64.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:40082 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbYJ1WZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:25:11 -0400
Received: by el-out-1112.google.com with SMTP id z25so914505ele.1
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 15:25:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h |   23 -----------------------
 1 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index e0c7dfa..753a983 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -732,29 +732,6 @@ extern int ipoib_debug_level;
 	do { (void) (priv); } while (0)
 #endif /* CONFIG_INFINIBAND_IPOIB_DEBUG_DATA */
 
-
-#define IPOIB_GID_FMT		"%2.2x%2.2x:%2.2x%2.2x:%2.2x%2.2x:%2.2x%2.2x:" \
-				"%2.2x%2.2x:%2.2x%2.2x:%2.2x%2.2x:%2.2x%2.2x"
-
-#define IPOIB_GID_RAW_ARG(gid)	((u8 *)(gid))[0], \
-				((u8 *)(gid))[1], \
-				((u8 *)(gid))[2], \
-				((u8 *)(gid))[3], \
-				((u8 *)(gid))[4], \
-				((u8 *)(gid))[5], \
-				((u8 *)(gid))[6], \
-				((u8 *)(gid))[7], \
-				((u8 *)(gid))[8], \
-				((u8 *)(gid))[9], \
-				((u8 *)(gid))[10],\
-				((u8 *)(gid))[11],\
-				((u8 *)(gid))[12],\
-				((u8 *)(gid))[13],\
-				((u8 *)(gid))[14],\
-				((u8 *)(gid))[15]
-
-#define IPOIB_GID_ARG(gid)	IPOIB_GID_RAW_ARG((gid).raw)
-
 #define IPOIB_QPN(ha) (be32_to_cpup((__be32 *) ha) & 0xffffff)
 
 #endif /* _IPOIB_H */
-- 
1.6.0.3.729.g6ea410

