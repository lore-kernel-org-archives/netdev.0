From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v6 3/3] sctp: fix up a spacing
Date: Tue, 10 Dec 2013 10:46:37 +0800
Message-ID: <1386643597-22156-4-git-send-email-wangweidong1@huawei.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18168 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3LJCrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:47:22 -0500
In-Reply-To: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix up spacing of proc_sctp_do_hmac_alg for according to the
proc_sctp_do_rto_min[max] in sysctl.c

Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index ed4ec89..9ae59a3 100644
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
