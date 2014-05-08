From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] rds: remove the unneed NULL checking
Date: Thu, 8 May 2014 17:01:53 +0800
Message-ID: <536B4801.9020802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <chien.yen@oracle.com>, <rds-devel@oss.oracle.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:60645 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbaEHJEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 05:04:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unregister_net_sysctl_table will check the ctl_table_header,
so remove the unneed checking

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/rds/iw_sysctl.c | 3 +--
 net/rds/sysctl.c    | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index 89c9151..139239d 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -111,8 +111,7 @@ static struct ctl_table rds_iw_sysctl_table[] = {
 
 void rds_iw_sysctl_exit(void)
 {
-	if (rds_iw_sysctl_hdr)
-		unregister_net_sysctl_table(rds_iw_sysctl_hdr);
+	unregister_net_sysctl_table(rds_iw_sysctl_hdr);
 }
 
 int rds_iw_sysctl_init(void)
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index b5cb2aa..c3b0cd4 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -94,8 +94,7 @@ static struct ctl_table rds_sysctl_rds_table[] = {
 
 void rds_sysctl_exit(void)
 {
-	if (rds_sysctl_reg_table)
-		unregister_net_sysctl_table(rds_sysctl_reg_table);
+	unregister_net_sysctl_table(rds_sysctl_reg_table);
 }
 
 int rds_sysctl_init(void)
-- 
1.7.12
