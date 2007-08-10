From: akpm@linux-foundation.org
Subject: [patch 04/28] Clean up duplicate includes in net/atm/
Date: Fri, 10 Aug 2007 14:11:51 -0700
Message-ID: <200708102111.l7ALBpV4009378@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53290 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942379AbXHJVML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/atm/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/lec.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/atm/lec.c~clean-up-duplicate-includes-in-net-atm net/atm/lec.c
--- a/net/atm/lec.c~clean-up-duplicate-includes-in-net-atm
+++ a/net/atm/lec.c
@@ -21,7 +21,6 @@
 #include <net/dst.h>
 #include <linux/proc_fs.h>
 #include <linux/spinlock.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
 /* TokenRing if needed */
_
