From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v3 2/2] RDS: TCP: Remove unused constant
Date: Tue, 15 Mar 2016 11:53:15 -0700
Message-ID: <46e6ca62f49240021c7b91da101edaa1a5e978f9.1458064902.git.sowmini.varadhan@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50946 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934149AbcCOSxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:53:36 -0400
In-Reply-To: <cover.1458064902.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1458064902.git.sowmini.varadhan@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS_TCP_DEFAULT_BUFSIZE has been unused since commit 1edd6a14d24f
("RDS-TCP: Do not bloat sndbuf/rcvbuf in rds_tcp_tune").

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v3: review comments from Santosh Shilimkar

 net/rds/tcp.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index b720b25..8b953c2 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -52,8 +52,6 @@ static LIST_HEAD(rds_tcp_conn_list);
 
 static struct kmem_cache *rds_tcp_conn_slab;
 
-#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
-
 static int sndbuf_handler(struct ctl_table *ctl, int write,
 			  void __user *buffer, size_t *lenp, loff_t *fpos);
 static int rcvbuf_handler(struct ctl_table *ctl, int write,
-- 
1.7.1
