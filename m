From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/2] lib names: Use CONFDIR for specify 'group' file path
Date: Sat,  6 Dec 2014 04:05:11 +0200
Message-ID: <1417831512-19452-2-git-send-email-vadim4j@gmail.com>
References: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:58480 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaLFCPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:15:00 -0500
Received: by mail-la0-f42.google.com with SMTP id gd6so1638241lab.1
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:14:58 -0800 (PST)
In-Reply-To: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 lib/rt_names.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 369e0f4..e6a1e01 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -469,7 +469,7 @@ static int rtnl_group_init;
 static void rtnl_group_initialize(void)
 {
 	rtnl_group_init = 1;
-	rtnl_hash_initialize("/etc/iproute2/group",
+	rtnl_hash_initialize(CONFDIR "/group",
 			     rtnl_group_hash, 256);
 }
 
-- 
2.1.3
