From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 04/10] 9P/RDMA: increase P9_RDMA_MAXSIZE to 1MB
Date: Tue,  2 Jul 2013 15:11:18 +0200
Message-ID: <1372770684-25573-5-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40972 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab3GBNlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:49 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current value is too low to get good performance.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index b1dfdf2..b8b66d3 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -57,9 +57,7 @@
 #define P9_RDMA_IRD		0
 #define P9_RDMA_ORD		0
 #define P9_RDMA_TIMEOUT		30000		/* 30 seconds */
-#define P9_RDMA_MAXSIZE		(4*4096)	/* Min SGE is 4, so we can
-						 * safely advertise a maxsize
-						 * of 64k */
+#define P9_RDMA_MAXSIZE		(1024*1024)	/* 1MB */
 
 /**
  * struct p9_trans_rdma - RDMA transport instance
-- 
1.7.2.2
