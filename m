From: Rami Rosen <ramirose@gmail.com>
Subject: [ PATCH iproute2] ss: replace bfp with bpf in usage().
Date: Fri, 24 May 2013 12:42:40 +0300
Message-ID: <1369388560-6030-1-git-send-email-ramirose@gmail.com>
Cc: stephen@networkplumber.org, Rami Rosen <ramirose@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:62432 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3EXJoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 05:44:11 -0400
Received: by mail-ea0-f181.google.com with SMTP id a11so2433691eae.40
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 02:44:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes usage() of misc/ss.c to use bpf instead of bfp.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 9f6354e..418dd6f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2926,7 +2926,7 @@ static void _usage(FILE *dest)
 "   -p, --processes	show process using socket\n"
 "   -i, --info		show internal TCP information\n"
 "   -s, --summary	show socket usage summary\n"
-"   -b, --bfp           show bpf filter socket information\n"
+"   -b, --bpf           show bpf filter socket information\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
-- 
1.8.1.4
