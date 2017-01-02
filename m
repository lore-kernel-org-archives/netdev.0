From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 04/17] RDS: IB: make the transport retry count smallest
Date: Mon,  2 Jan 2017 14:45:39 -0800
Message-ID: <1483397152-8307-5-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transport retry is not much useful since it indicate packet loss
in fabric so its better to failover fast rather than longer retry.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 45ac8e8..f4e8121 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -16,7 +16,7 @@
 #define RDS_IB_DEFAULT_SEND_WR		256
 #define RDS_IB_DEFAULT_FR_WR		512
 
-#define RDS_IB_DEFAULT_RETRY_COUNT	2
+#define RDS_IB_DEFAULT_RETRY_COUNT	1
 
 #define RDS_IB_SUPPORTED_PROTOCOLS	0x00000003	/* minor versions supported */
 
-- 
1.9.1
