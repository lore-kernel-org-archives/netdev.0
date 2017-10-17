From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netfilter: ip6_tables: remove redundant assignment to e
Date: Tue, 17 Oct 2017 13:02:00 +0100
Message-ID: <20171017120200.19994-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The assignment to variable e is redundant since the same assignment
occurs just a few lines later, hence it can be removed.  Cleans up
clang warning: warning: Value stored to 'e' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv6/netfilter/ip6_tables.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 01bd3ee5ebc6..702e483d38b0 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -458,7 +458,6 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					if (!xt_find_jump_offset(offsets, newpos,
 								 newinfo->number))
 						return 0;
-					e = entry0 + newpos;
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
-- 
2.14.1

