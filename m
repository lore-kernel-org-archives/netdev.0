From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Subject: [PATCH] net: vrf: replace hard tab with space in assignment
Date: Tue, 21 Jun 2016 15:39:43 +1200
Message-ID: <20160621033943.21947-1-chris.packham@alliedtelesis.co.nz>
Cc: linux-kernel@vger.kernel.org, shm@cumulusnetworks.com,
	dsa@cumulusnetworks.com,
	Chris Packham <chris.packham@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The assignment of rth->dst.output in vrf_rt6_create() and
vrf_rtable_create() used a hard tab before the '='. The neighboring
assignments did not. Make the assignment of rth->dst.output consistent
with the surrounding code.

Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
---
 drivers/net/vrf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index dff08842f26d..8bd8c7e1ee87 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -304,7 +304,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	dst_hold(&rt6->dst);
 
 	rt6->rt6i_table = rt6i_table;
-	rt6->dst.output	= vrf_output6;
+	rt6->dst.output = vrf_output6;
 	rcu_assign_pointer(vrf->rt6, rt6);
 
 	rc = 0;
@@ -403,7 +403,7 @@ static int vrf_rtable_create(struct net_device *dev)
 	if (!rth)
 		return -ENOMEM;
 
-	rth->dst.output	= vrf_output;
+	rth->dst.output = vrf_output;
 	rth->rt_table_id = vrf->tb_id;
 
 	rcu_assign_pointer(vrf->rth, rth);
-- 
2.8.4
