From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v4 2/2] RDS: TCP: Remove unused constant
Date: Wed, 16 Mar 2016 11:38:13 -0700
Message-ID: <7602e29d0acf5af176b734c6249263357a264323.1458152609.git.sowmini.varadhan@oracle.com>
References: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com, hannes@stressinduktion.org,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24159 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935152AbcCPSim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 14:38:42 -0400
In-Reply-To: <cover.1458152608.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1458152608.git.sowmini.varadhan@oracle.com>
References: <cover.1458152608.git.sowmini.varadhan@oracle.com>
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
index 3802785..61ed2a8 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -52,8 +52,6 @@ static LIST_HEAD(rds_tcp_conn_list);
 
 static struct kmem_cache *rds_tcp_conn_slab;
 
-#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
-
 static int rds_tcp_skbuf_handler(struct ctl_table *ctl, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *fpos);
-- 
1.7.1
