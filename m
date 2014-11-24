From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net_test_tools] route_bench: Fix bug in DST_ITERATE option
Date: Mon, 24 Nov 2014 00:13:39 -0800
Message-ID: <1416816819-17310-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:32890 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbaKXIOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 03:14:41 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so7150494pdj.9
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 00:14:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While setting option for dst_addr_stride, flags should be set for
FLAG_DST_ITERATE not FLAG_SRC_ITERATE.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 route_bench.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/route_bench.c b/route_bench.c
index eb91dcf..22cbd2a 100644
--- a/route_bench.c
+++ b/route_bench.c
@@ -292,7 +292,7 @@ int main(int argc, char **argv, char **envp)
 			break;
 		case 'e':
 			sscanf(optarg, "%u", &s->dst_addr_stride);
-			s->flags |= FLAG_SRC_ITERATE;
+			s->flags |= FLAG_DST_ITERATE;
 			break;
 		case 'f':
 			s->dst_addr_limit = inet_addr(optarg);
-- 
1.7.9.5
