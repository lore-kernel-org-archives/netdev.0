From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 05/15] RDS/RDMA: Fix cut-n-paste errors in printks in rdma_transport.c
Date: Fri, 17 Jul 2009 16:13:26 -0700
Message-ID: <1247872416-17834-6-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:51718 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758012AbZGQXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:13:59 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNDfPZ003443
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:13:43 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma_transport.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 7d0f901..981a5e6 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -101,7 +101,7 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 		break;
 
 	case RDMA_CM_EVENT_DISCONNECTED:
-		printk(KERN_WARNING "RDS/IW: DISCONNECT event - dropping connection "
+		printk(KERN_WARNING "RDS/RDMA: DISCONNECT event - dropping connection "
 			"%pI4->%pI4\n", &conn->c_laddr,
 			 &conn->c_faddr);
 		rds_conn_drop(conn);
@@ -132,7 +132,7 @@ static int __init rds_rdma_listen_init(void)
 	cm_id = rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_TCP);
 	if (IS_ERR(cm_id)) {
 		ret = PTR_ERR(cm_id);
-		printk(KERN_ERR "RDS/IW: failed to setup listener, "
+		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
 		       "rdma_create_id() returned %d\n", ret);
 		goto out;
 	}
@@ -147,14 +147,14 @@ static int __init rds_rdma_listen_init(void)
 	 */
 	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&sin);
 	if (ret) {
-		printk(KERN_ERR "RDS/IW: failed to setup listener, "
+		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
 		       "rdma_bind_addr() returned %d\n", ret);
 		goto out;
 	}
 
 	ret = rdma_listen(cm_id, 128);
 	if (ret) {
-		printk(KERN_ERR "RDS/IW: failed to setup listener, "
+		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
 		       "rdma_listen() returned %d\n", ret);
 		goto out;
 	}
-- 
1.6.0.4

