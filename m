From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v5 2/2] sctp: fix up a spacing
Date: Sat, 7 Dec 2013 15:17:31 +0800
Message-ID: <1386400651-21744-3-git-send-email-wangweidong1@huawei.com>
References: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:1628 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3LGHSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 02:18:07 -0500
In-Reply-To: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix up spacing of proc_sctp_do_hmac_alg for according to the
proc_sctp_do_rto_min[max] in sysctl.c

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 33c56c6..0ea22b7 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -56,10 +56,8 @@ extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
-static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
-				int write,
+static int proc_sctp_do_hmac_alg(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
-
 				loff_t *ppos);
 static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
@@ -301,8 +299,7 @@ static struct ctl_table sctp_net_table[] = {
 	{ /* sentinel */ }
 };
 
-static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
-				int write,
+static int proc_sctp_do_hmac_alg(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
 				loff_t *ppos)
 {
-- 
1.7.12
