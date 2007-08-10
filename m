From: akpm@linux-foundation.org
Subject: [patch 10/28] Clean up duplicate includes in  net/xfrm/
Date: Fri, 10 Aug 2007 14:11:54 -0700
Message-ID: <200708102111.l7ALBt8h009400@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57416 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S940849AbXHJVMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/xfrm/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/xfrm/xfrm_policy.c |    3 +--
 net/xfrm/xfrm_state.c  |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -puN net/xfrm/xfrm_policy.c~clean-up-duplicate-includes-in-net-xfrm net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c~clean-up-duplicate-includes-in-net-xfrm
+++ a/net/xfrm/xfrm_policy.c
@@ -23,10 +23,9 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/audit.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
-#include <linux/audit.h>
-#include <linux/cache.h>
 
 #include "xfrm_hash.h"
 
diff -puN net/xfrm/xfrm_state.c~clean-up-duplicate-includes-in-net-xfrm net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c~clean-up-duplicate-includes-in-net-xfrm
+++ a/net/xfrm/xfrm_state.c
@@ -19,9 +19,8 @@
 #include <linux/ipsec.h>
 #include <linux/module.h>
 #include <linux/cache.h>
-#include <asm/uaccess.h>
 #include <linux/audit.h>
-#include <linux/cache.h>
+#include <asm/uaccess.h>
 
 #include "xfrm_hash.h"
 
_
