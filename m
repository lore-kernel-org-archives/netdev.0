From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH 7/9] RDS: IB: Remove an unused structure member
Date: Tue, 10 Jan 2017 16:56:46 -0800
Message-ID: <20170111005648.14988-8-bart.vanassche@sandisk.com>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Santosh Shilimkar" <ssantosh@kernel.org>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rds-devel@oss.oracle.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170111005648.14988-1-bart.vanassche@sandisk.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Santosh Shilimkar <ssantosh@kernel.org>
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-rdma@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: rds-devel@oss.oracle.com
---
 net/rds/ib_mr.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 1c754f4acbe5..24c086db4511 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -45,7 +45,6 @@
 
 struct rds_ib_fmr {
 	struct ib_fmr		*fmr;
-	u64			*dma;
 };
 
 enum rds_ib_fr_state {
-- 
2.11.0
