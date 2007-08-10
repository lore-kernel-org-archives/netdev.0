From: akpm@linux-foundation.org
Subject: [patch 08/28] Clean up duplicate includes in net/sunrpc/
Date: Fri, 10 Aug 2007 14:11:53 -0700
Message-ID: <200708102111.l7ALBreC009394@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com, neilb@suse.de, trond.myklebust@fys.uio.no
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46041 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S940849AbXHJVMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/sunrpc/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Neil Brown <neilb@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/auth_gss/svcauth_gss.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/sunrpc/auth_gss/svcauth_gss.c~clean-up-duplicate-includes-in-net-sunrpc net/sunrpc/auth_gss/svcauth_gss.c
--- a/net/sunrpc/auth_gss/svcauth_gss.c~clean-up-duplicate-includes-in-net-sunrpc
+++ a/net/sunrpc/auth_gss/svcauth_gss.c
@@ -42,7 +42,6 @@
 #include <linux/pagemap.h>
 
 #include <linux/sunrpc/auth_gss.h>
-#include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/sunrpc/svcauth_gss.h>
_
