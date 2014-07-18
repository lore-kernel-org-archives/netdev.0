From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range check just before the check for equality
Date: Fri, 18 Jul 2014 18:33:58 +0300
Message-ID: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com>
Cc: dcb314@hotmail.com, davem@davemloft.net, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, ja@ssi.bg,
	horms@verge.net.au, wensong@linux-vs.org,
	Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=80601
Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 581a658..4ed7b59 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2338,8 +2338,6 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
 		return -EINVAL;
-	if (len < 0 || len >  MAX_ARG_LEN)
-		return -EINVAL;
 	if (len != set_arglen[SET_CMDID(cmd)]) {
 		pr_err("set_ctl: len %u != %u\n",
 		       len, set_arglen[SET_CMDID(cmd)]);
-- 
1.8.5.5
