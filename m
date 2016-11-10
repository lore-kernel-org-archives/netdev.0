From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/14] ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr
Date: Thu, 10 Nov 2016 01:23:43 +0100
Message-ID: <1478737427-1574-11-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WANG Cong <xiyou.wangcong@gmail.com>

family.maxattr is the max index for policy[], the size of
ops[] is determined with ARRAY_SIZE().

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b2e712..a6e44ef2ec9a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2845,7 +2845,7 @@ static struct genl_family ip_vs_genl_family = {
 	.hdrsize	= 0,
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
-	.maxattr	= IPVS_CMD_MAX,
+	.maxattr	= IPVS_CMD_ATTR_MAX,
 	.netnsok        = true,         /* Make ipvsadm to work on netns */
 };
 
-- 
2.1.4

