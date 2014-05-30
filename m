From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] RDS/RDMA: Replace comma with semicolon
Date: Fri, 30 May 2014 21:16:05 +0530
Message-ID: <20140530154605.GA4049@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces a comma between expression statements by a semicolon.

A simplified version of the semantic patch that performs this
transformation is as follows:

// <smpl>
@r@
expression e1,e2,e;
type T;
identifier i;
@@

 e1
-,
+;
 e2;
// </smpl>


Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: Chien Yen <chien.yen@oracle.com>,"David S. Miller" <davem@davemloft.net>,rds-devel@oss.oracle.com,netdev@vger.kernel.org,linux-kernel@vger.kernel.org

 net/rds/rdma_transport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index c2be901..6cd9d1d 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -168,7 +168,7 @@ static int rds_rdma_listen_init(void)
 		return ret;
 	}
 
-	sin.sin_family = AF_INET,
+	sin.sin_family = AF_INET;
 	sin.sin_addr.s_addr = (__force u32)htonl(INADDR_ANY);
 	sin.sin_port = (__force u16)htons(RDS_PORT);
 
-- 
1.9.1
