From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/53] netfilter: xt_helper: Use sizeof(variable) instead of literal number
Date: Mon, 26 Sep 2016 01:06:44 +0200
Message-ID: <1474844823-2026-35-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

It's better to use sizeof(info->name)-1 as index to force set the string
tail instead of literal number '29'.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_helper.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 9f4ab00c8050..805c9f64a04c 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -65,7 +65,7 @@ static int helper_mt_check(const struct xt_mtchk_param *par)
 			par->family);
 		return ret;
 	}
-	info->name[29] = '\0';
+	info->name[sizeof(info->name) - 1] = '\0';
 	return 0;
 }
 
-- 
2.1.4

