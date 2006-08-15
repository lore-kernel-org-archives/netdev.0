From: akpm@osdl.org
Subject: [patch 08/13] netfilter: make unused signal code go away so nobody copies its brokenness
Date: Mon, 14 Aug 2006 23:03:42 -0700
Message-ID: <200608150603.k7F63geM012945@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	alan@redhat.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55955 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965169AbWHOGEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:04:06 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

This code is wrong on so many levels, please lose it so it isn't replicated
anywhere else.

Signed-off-by: Alan Cox <alan@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/bridge/netfilter/ebtables.c |   21 ---------------------
 1 file changed, 21 deletions(-)

diff -puN net/bridge/netfilter/ebtables.c~netfilter-make-unused-signal-code-go-away-so-nobody-copies-its-broken-ness net/bridge/netfilter/ebtables.c
--- a/net/bridge/netfilter/ebtables.c~netfilter-make-unused-signal-code-go-away-so-nobody-copies-its-broken-ness
+++ a/net/bridge/netfilter/ebtables.c
@@ -37,30 +37,9 @@
 #include <linux/netfilter_ipv4/listhelp.h>
 #include <linux/mutex.h>
 
-#if 0
-/* use this for remote debugging
- * Copyright (C) 1998 by Ori Pomerantz
- * Print the string to the appropriate tty, the one
- * the current task uses
- */
-static void print_string(char *str)
-{
-	struct tty_struct *my_tty;
-
-	/* The tty for the current task */
-	my_tty = current->signal->tty;
-	if (my_tty != NULL) {
-		my_tty->driver->write(my_tty, 0, str, strlen(str));
-		my_tty->driver->write(my_tty, 0, "\015\012", 2);
-	}
-}
-
-#define BUGPRINT(args) print_string(args);
-#else
 #define BUGPRINT(format, args...) printk("kernel msg: ebtables bug: please "\
                                          "report to author: "format, ## args)
 /* #define BUGPRINT(format, args...) */
-#endif
 #define MEMPRINT(format, args...) printk("kernel msg: ebtables "\
                                          ": out of memory: "format, ## args)
 /* #define MEMPRINT(format, args...) */
_
