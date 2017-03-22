From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH 2/2] netfilter: ipset: warn users of list:set that parameter 'size' is ignored
Date: Tue, 21 Mar 2017 22:06:22 -0400
Message-ID: <1490148382-2633-2-git-send-email-vpai@akamai.com>
References: <1490148382-2633-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, vpai@akamai.com,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        coreteam@netfilter.org, pai.vishwain@gmail.com
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1490148382-2633-1-git-send-email-vpai@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revision 4 warns the users that the parameter 'size' is ignored. The
kernel module doesn't need any changes, it will work with both the
revisions.

Note that this will not restore old behavior before commit 00590fdd5be0
("netfilter: ipset: Introduce RCU locking in list type") for users of
the older revision. It will be a much bigger change if that is
what we need.

Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 net/netfilter/ipset/ip_set_list_set.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 178d4eb..d4f820a 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -19,7 +19,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1    Counters support added */
 /*				2    Comments support added */
-#define IPSET_TYPE_REV_MAX	3 /* skbinfo support added */
+/*				3    skbinfo support added */
+#define IPSET_TYPE_REV_MAX	4 /* size argument is ignored */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-- 
1.9.1

