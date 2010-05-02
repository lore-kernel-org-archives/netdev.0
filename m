From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH] net: fix compile error due to double return type in SOCK_DEBUG
Date: Sun,  2 May 2010 20:00:01 +0200
Message-ID: <1272823202-25957-1-git-send-email-jengelh@medozas.de>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:40029 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758334Ab0EBSAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 May 2010 14:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this one:
include/net/sock.h: error: two or more data types in declaration specifiers

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/net/sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..0f0b6d6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -74,7 +74,7 @@
 					printk(KERN_DEBUG msg); } while (0)
 #else
 /* Validate arguments and do nothing */
-static void inline int __attribute__ ((format (printf, 2, 3)))
+static inline void __attribute__ ((format (printf, 2, 3)))
 SOCK_DEBUG(struct sock *sk, const char *msg, ...)
 {
 }
-- 
1.7.0.5

