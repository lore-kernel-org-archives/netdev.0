From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr
Date: Thu,  3 Nov 2016 17:14:03 -0700
Message-ID: <1478218443-11616-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: netfilter-devel@vger.kernel.org, andreyknvl@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

family.maxattr is the max index for policy[], the size of
ops[] is determined with ARRAY_SIZE().

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b..a6e44ef 100644
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
2.1.0

