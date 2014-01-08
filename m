From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Wed, 8 Jan 2014 10:56:40 +0800
Message-ID: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55706 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627AbaAHC4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:56:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix below sparse warning:

net/ipv6/xfrm6_state.c:66:26: error: cannot size expression

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/ipv6/xfrm6_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3fc9701..0c10dff 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -63,7 +63,7 @@ __xfrm6_sort(void **dst, void **src, int n, int (*cmp)(void *p), int maxclass)
 	int class[XFRM_MAX_DEPTH];
 	int count[maxclass];
 
-	memset(count, 0, sizeof(count));
+	memset(count, 0, sizeof(int) * maxclass);
 
 	for (i = 0; i < n; i++) {
 		int c;
-- 
1.7.9.5
