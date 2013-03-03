From: Claudiu Ghioc <claudiughioc@gmail.com>
Subject: [PATCH] filter: fix sparse warning for bpf_internal_load_pointer_neg_helper
Date: Mon,  4 Mar 2013 01:30:04 +0200
Message-ID: <1362353404-27034-1-git-send-email-claudiu.ghioc@gmail.com>
Cc: edumazet@google.com, dborkman@redhat.com, jpirko@redhat.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Claudiu Ghioc <claudiu.ghioc@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed the following sparse warning:
*   net/core/filter.c:48:6: warning: symbol
    'bpf_internal_load_pointer_neg_helper' was
    not declared. Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 2e20b55..f6c907c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -45,7 +45,7 @@
  *
  * Exported for the bpf jit load helper.
  */
-void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
+static void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
 {
 	u8 *ptr = NULL;
 
-- 
1.7.10.4
