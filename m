From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH 1/2] net: phonet: mark header_ops as const
Date: Sat, 30 Sep 2017 17:08:39 +0800
Message-ID: <1506762519-4709-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, courmisch@gmail.com,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34999 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbdI3JIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 05:08:44 -0400
Received: by mail-pg0-f65.google.com with SMTP id j16so1313133pga.2
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 02:08:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/phonet/af_phonet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index f925753..b12142e 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -149,7 +149,7 @@ static int pn_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 	return 1;
 }
 
-struct header_ops phonet_header_ops = {
+const struct header_ops phonet_header_ops = {
 	.create = pn_header_create,
 	.parse = pn_header_parse,
 };
-- 
1.8.3.1
