From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: recompute the array size
Date: Fri,  4 Apr 2014 14:51:26 +0800
Message-ID: <1396594286-21788-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:39353 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbaDDGvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 02:51:31 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so3030622pbc.32
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 23:51:30 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id cz3sm15579357pbc.9.2014.04.03.23.51.27
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 23:51:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

recompute the array size to kill the warning:
 net/ipv6/xfrm6_state.c:66:26: error: cannot size expression

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/xfrm6_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3fc9701..9e08572 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -63,7 +63,7 @@ __xfrm6_sort(void **dst, void **src, int n, int (*cmp)(void *p), int maxclass)
 	int class[XFRM_MAX_DEPTH];
 	int count[maxclass];
 
-	memset(count, 0, sizeof(count));
+	memset(count, 0, sizeof(int)*maxclass);
 
 	for (i = 0; i < n; i++) {
 		int c;
-- 
1.7.10.4
