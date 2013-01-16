From: Benjamin Kerensa <bkerensa@ubuntu.com>
Subject: [PATCH] Remove excessive punctuation from ping flood warning
Date: Wed, 16 Jan 2013 03:10:13 -0800
Message-ID: <50F68A95.5080203@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44155 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758127Ab3APLKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 06:10:15 -0500
Received: by mail-pa0-f48.google.com with SMTP id fa1so730989pad.35
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 03:10:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes excessive punctuation from the flood warning.

 From 932b1fc65d0f93531d2277831c6a584c9b1cfe63 Mon Sep 17 00:00:00 2001
From: Benjamin Kerensa <bkerensa@ubuntu.com>
Date: Wed, 16 Jan 2013 02:53:38 -0800
Subject: [PATCH] Remove excessive punctuation from ping flood warning
Signed-off-by: Benjamin Kerensa <bkerensa@ubuntu.com
---
  ping_common.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ping_common.c b/ping_common.c
index 7f82851..261aafc 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -608,7 +608,7 @@ void setup(int icmp_sock)
          interval = 0;

      if (uid && interval < MINUSERINTERVAL) {
-        fprintf(stderr, "ping: cannot flood; minimal interval, allowed 
for user, is %dms\n", MINUSERINTERVAL);
+        fprintf(stderr, "ping: cannot flood; minimal interval allowed 
for user is %dms\n", MINUSERINTERVAL);
          exit(2);
      }

-- 
1.8.0
