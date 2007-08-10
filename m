From: akpm@linux-foundation.org
Subject: [patch 07/28] Clean up duplicate includes in net/sched/
Date: Fri, 10 Aug 2007 14:11:53 -0700
Message-ID: <200708102111.l7ALBrtS009391@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56912 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942365AbXHJVMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/sched/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sched/act_police.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/sched/act_police.c~clean-up-duplicate-includes-in-net-sched net/sched/act_police.c
--- a/net/sched/act_police.c~clean-up-duplicate-includes-in-net-sched
+++ a/net/sched/act_police.c
@@ -16,7 +16,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
-#include <linux/module.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <net/act_api.h>
_
