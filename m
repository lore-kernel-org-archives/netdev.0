From: Suraj Deshmukh <surajssd009005@gmail.com>
Subject: [PATCH] net: af_mpls.c add space before open parenthesis
Date: Sat,  3 Dec 2016 07:59:26 +0000
Message-ID: <20161203075926.7890-1-surajssd009005@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Suraj Deshmukh <surajssd009005@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding space after switch keyword before open
parenthesis for readability purpose.

This patch fixes the checkpatch.pl warning:
space required before the open parenthesis '('

Signed-off-by: Suraj Deshmukh <surajssd009005@gmail.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0e4334c..15fe976 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1252,7 +1252,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		if (!nla)
 			continue;
 
-		switch(index) {
+		switch (index) {
 		case RTA_OIF:
 			cfg->rc_ifindex = nla_get_u32(nla);
 			break;
-- 
2.9.3
