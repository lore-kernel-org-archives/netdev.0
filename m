From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/6] net_sched: cls_bpf: use tabs to do indent
Date: Tue, 10 Dec 2013 20:55:30 +0800
Message-ID: <1386680134-85452-3-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:4252 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab3LJMzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:47 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code indent should use tabs where possible

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/cls_bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1002a82..d7c72be 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -323,7 +323,7 @@ static int cls_bpf_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nla == NULL)
 		goto nla_put_failure;
 
-        memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
 
 	if (tcf_exts_dump(skb, &prog->exts, &bpf_ext_map) < 0)
 		goto nla_put_failure;
-- 
1.8.0
