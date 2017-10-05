From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH v3 1/2] net: phonet: mark header_ops as const
Date: Fri,  6 Oct 2017 01:37:29 +0800
Message-ID: <1507225049-45910-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, Lin Zhang <xiaolou4617@gmail.com>
To: courmisch@gmail.co, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:56570 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751278AbdJEJhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 05:37:42 -0400
Received: by mail-it0-f67.google.com with SMTP id g18so575595itg.5
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 02:37:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
changelog:

v2 -> v3:
	* fix phonet_header_ops type mismatch error
---
 include/linux/if_phonet.h | 2 +-
 net/phonet/af_phonet.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
index bbcdb0a..a118ee4 100644
--- a/include/linux/if_phonet.h
+++ b/include/linux/if_phonet.h
@@ -10,5 +10,5 @@
 
 #include <uapi/linux/if_phonet.h>
 
-extern struct header_ops phonet_header_ops;
+extern const struct header_ops phonet_header_ops;
 #endif
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
