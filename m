From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/29] netfilter: fix spelling mistake: "delimitter" -> "delimiter"
Date: Mon,  5 Sep 2016 12:58:28 +0200
Message-ID: <1473073124-5015-14-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in pr_debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 4314700..b6934b5 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -237,7 +237,7 @@ static int try_eprt(const char *data, size_t dlen, struct nf_conntrack_man *cmd,
 	}
 	delim = data[0];
 	if (isdigit(delim) || delim < 33 || delim > 126 || data[2] != delim) {
-		pr_debug("try_eprt: invalid delimitter.\n");
+		pr_debug("try_eprt: invalid delimiter.\n");
 		return 0;
 	}
 
-- 
2.1.4

