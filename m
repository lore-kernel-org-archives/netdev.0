From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 4/5] rds: remove the unused variable
Date: Mon, 27 Mar 2017 03:06:29 -0400
Message-ID: <1490598390-13812-5-git-send-email-yanjun.zhu@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu@oracle.com, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, junxiao.bi@oracle.com, joe.jin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45349 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdC0HHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 03:07:03 -0400
In-Reply-To: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function rds_ib_recv_path, the variable ret is not used.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 net/rds/ib_recv.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index e10624a..be8d2f2 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -1023,7 +1023,6 @@ int rds_ib_recv_path(struct rds_conn_path *cp)
 {
 	struct rds_connection *conn = cp->cp_conn;
 	struct rds_ib_connection *ic = conn->c_transport_data;
-	int ret = 0;
 
 	rdsdebug("conn %p\n", conn);
 	if (rds_conn_up(conn)) {
@@ -1031,7 +1030,7 @@ int rds_ib_recv_path(struct rds_conn_path *cp)
 		rds_ib_recv_refill(conn, 0, GFP_KERNEL);
 	}
 
-	return ret;
+	return 0;
 }
 
 int rds_ib_recv_init(void)
-- 
2.7.4
