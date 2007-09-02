From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] net/ipv4/af_inet.c: use ARRAY_SIZE macro from kernel.h instead
Date: Sun,  2 Sep 2007 12:59:07 +0800
Message-ID: <11887091471748-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:32191 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbXIBE7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 00:59:31 -0400
Received: by rv-out-0910.google.com with SMTP id k20so696693rvb
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2007 21:59:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e681034..d5e8b67 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -939,7 +939,7 @@ static struct inet_protosw inetsw_array[] =
        }
 };
 
-#define INETSW_ARRAY_LEN (sizeof(inetsw_array) / sizeof(struct inet_protosw))
+#define INETSW_ARRAY_LEN ARRAY_SIZE(inetsw_array)
 
 void inet_register_protosw(struct inet_protosw *p)
 {
-- 
1.5.3.rc7

