From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] netfilter: remove unnecessary sizeof(char)
Date: Mon, 22 Dec 2014 19:36:15 +0100
Message-ID: <1419273375-24312-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sizeof(char) is always 1.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netfilter/nf_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 43c926c..1191f66 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -426,7 +426,7 @@ static int netfilter_log_sysctl_init(struct net *net)
 				nf_log_sysctl_fnames[i];
 			nf_log_sysctl_table[i].data = NULL;
 			nf_log_sysctl_table[i].maxlen =
-				NFLOGGER_NAME_LEN * sizeof(char);
+				NFLOGGER_NAME_LEN;
 			nf_log_sysctl_table[i].mode = 0644;
 			nf_log_sysctl_table[i].proc_handler =
 				nf_log_proc_dostring;
-- 
1.9.1
