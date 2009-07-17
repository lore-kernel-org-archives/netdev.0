From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 07/15] RDS: Don't set c_version in __rds_conn_create()
Date: Fri, 17 Jul 2009 16:13:28 -0700
Message-ID: <1247872416-17834-8-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:51749 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758013AbZGQXOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:14:02 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNDi9l003498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:13:46 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protocol negotiation is logically a property of the
transports, so rds core need not set it.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/connection.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index d14445c..605fe3f 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -155,7 +155,6 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	}
 
 	INIT_HLIST_NODE(&conn->c_hash_node);
-	conn->c_version = RDS_PROTOCOL_3_0;
 	conn->c_laddr = laddr;
 	conn->c_faddr = faddr;
 	spin_lock_init(&conn->c_lock);
-- 
1.6.0.4

