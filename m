From: tcharding <me@tobin.cc>
Subject: [PATCH 3/3] bridge: netfilter: checkpatch null comparison fixes
Date: Tue, 10 May 2016 11:26:58 +1000
Message-ID: <1462843618-21914-4-git-send-email-me@tobin.cc>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
Cc: Tobin C Harding <me@tobin.cc>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462843618-21914-1-git-send-email-me@tobin.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobin C Harding <me@tobin.cc>

checkpatch produces comparison to null 'checks'.

This patch amends them.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 net/bridge/netfilter/ebt_stp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 9df943f..677904f 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -128,7 +128,7 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const u8 header[6] = {0x42, 0x42, 0x03, 0x00, 0x00, 0x00};
 
 	sp = skb_header_pointer(skb, 0, sizeof(_stph), &_stph);
-	if (sp == NULL)
+	if (!sp)
 		return false;
 
 	/* The stp code only considers these */
@@ -146,7 +146,7 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 		st = skb_header_pointer(skb, sizeof(_stph),
 					sizeof(_stpc), &_stpc);
-		if (st == NULL)
+		if (!st)
 			return false;
 		return ebt_filter_config(info, st);
 	}
-- 
2.8.2

