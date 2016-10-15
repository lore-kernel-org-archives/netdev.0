From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] rds: Remove duplicate prefix from rds_conn_path_error use
Date: Sat, 15 Oct 2016 11:53:22 -0700
Message-ID: <832b0d2c1b31c10db7692f65f1ba77e779db15e1.1476557523.git.joe@perches.com>
References: <cover.1476557523.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1476557523.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rds_conn_path_error already prefixes "RDS:" to the output.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rds/threads.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rds/threads.c b/net/rds/threads.c
index e42df11bf30a..e36e333a0aa0 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -171,8 +171,7 @@ void rds_connect_worker(struct work_struct *work)
 						     RDS_CONN_DOWN))
 				rds_queue_reconnect(cp);
 			else
-				rds_conn_path_error(cp,
-						    "RDS: connect failed\n");
+				rds_conn_path_error(cp, "connect failed\n");
 		}
 	}
 }
-- 
2.10.0.rc2.1.g053435c
