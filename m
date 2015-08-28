From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next] sock: fix kernel doc error
Date: Thu, 27 Aug 2015 18:05:49 -0600
Message-ID: <1440720349-10448-1-git-send-email-sakiwit@gmail.com>
Cc: Hideo Aoki <haoki@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35038 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbH1ACq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 20:02:46 -0400
Received: by pacdd16 with SMTP id dd16so41554218pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 17:02:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The symbol '__sk_reclaim' is not present in the current tree. Apparently
'__sk_reclaim' was meant to be '__sk_mem_reclaim', so fix it with the
right symbol name for the kernel doc.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Hideo Aoki <haoki@redhat.com>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 193901d09757..ca2984afe16e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2078,7 +2078,7 @@ suppress_allocation:
 EXPORT_SYMBOL(__sk_mem_schedule);
 
 /**
- *	__sk_reclaim - reclaim memory_allocated
+ *	__sk_mem_reclaim - reclaim memory_allocated
  *	@sk: socket
  *	@amount: number of bytes (rounded down to a SK_MEM_QUANTUM multiple)
  */
