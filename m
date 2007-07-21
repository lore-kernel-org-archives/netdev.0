From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][34/37] Clean up duplicate includes in  net/xfrm/
Date: Sat, 21 Jul 2007 17:04:01 +0200
Message-ID: <200707211704.01339.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, netdev@vger.kernel.org,
	David S Miller <davem@davemloft.net>,
	Kunihiro Ishiguro <kunihiro@ipinfusion.com>,
	Derek Atkins <derek@ihtfp.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:39667 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939493AbXGUPE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:59 -0400
Received: by ug-out-1314.google.com with SMTP id j3so800074ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/xfrm/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c3a4b0a..e67489a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
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
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 38f90ca..b2552b1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -19,9 +19,8 @@
 #include <linux/ipsec.h>
 #include <linux/module.h>
 #include <linux/cache.h>
-#include <asm/uaccess.h>
 #include <linux/audit.h>
-#include <linux/cache.h>
+#include <asm/uaccess.h>
 
 #include "xfrm_hash.h"
 
