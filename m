From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH v2 11/26] RDS: IB: Remove an unused structure member
Date: Thu, 12 Jan 2017 11:07:03 -0800
Message-ID: <20170112190718.6728-12-bart.vanassche@sandisk.com>
References: <20170112190718.6728-1-bart.vanassche@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rds-devel@oss.oracle.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0062.outbound.protection.outlook.com ([104.47.34.62]:3808
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750911AbdALTIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 14:08:10 -0500
In-Reply-To: <20170112190718.6728-1-bart.vanassche@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
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
