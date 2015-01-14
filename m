From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] netfilter: log: remove unnecessary sizeof(char)
Date: Wed, 14 Jan 2015 21:34:44 +0100
Message-ID: <1421267689-24894-4-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49662 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249AbbANUcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 15:32:06 -0500
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>

sizeof(char) is always 1.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 43c926c..0d8448f 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -425,8 +425,7 @@ static int netfilter_log_sysctl_init(struct net *net)
 			nf_log_sysctl_table[i].procname	=
 				nf_log_sysctl_fnames[i];
 			nf_log_sysctl_table[i].data = NULL;
-			nf_log_sysctl_table[i].maxlen =
-				NFLOGGER_NAME_LEN * sizeof(char);
+			nf_log_sysctl_table[i].maxlen = NFLOGGER_NAME_LEN;
 			nf_log_sysctl_table[i].mode = 0644;
 			nf_log_sysctl_table[i].proc_handler =
 				nf_log_proc_dostring;
-- 
1.7.10.4
