From: Tom Herbert <therbert@google.com>
Subject: [PATCH] dql: Fix undefined jiffies
Date: Sun, 11 Mar 2012 19:58:08 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1203111955270.6831@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f74.google.com ([209.85.215.74]:58585 "EHLO
	mail-lpp01m010-f74.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770Ab2CLC6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 22:58:10 -0400
Received: by laai8 with SMTP id i8so190012laa.1
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 19:58:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some configurations, jiffies may be undefined in
lib/dynamic_queue_limits.c.  Adding include of jiffies.h to avoid
this.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 lib/dynamic_queue_limits.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index 3d1bdcd..6ab4587 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -7,6 +7,7 @@
 #include <linux/types.h>
 #include <linux/ctype.h>
 #include <linux/kernel.h>
+#include <linux/jiffies.h>
 #include <linux/dynamic_queue_limits.h>
 
 #define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
-- 
1.7.7.3
