From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 04/15] RDS/IB: Fix printk to indicate remote IP, not local
Date: Fri, 17 Jul 2009 16:13:25 -0700
Message-ID: <1247872416-17834-5-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26046 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758039AbZGQXov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:51 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNivkC007935
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:44:58 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_cm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 1eb0c29..f621086 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -111,7 +111,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	}
 
 	printk(KERN_NOTICE "RDS/IB: connected to %pI4 version %u.%u%s\n",
-			&conn->c_laddr,
+			&conn->c_faddr,
 			RDS_PROTOCOL_MAJOR(conn->c_version),
 			RDS_PROTOCOL_MINOR(conn->c_version),
 			ic->i_flowctl ? ", flow control" : "");
-- 
1.6.0.4

