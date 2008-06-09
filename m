From: akpm@linux-foundation.org
Subject: [patch 07/13] smc911x: remove unused 8-bit I/O operations
Date: Mon, 09 Jun 2008 16:33:53 -0700
Message-ID: <200806092333.m59NXrU8014688@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45095 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756479AbYFIXeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

Remove unused SMC_inb() and SMC_outb() functions.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.h |    4 ----
 1 file changed, 4 deletions(-)

diff -puN drivers/net/smc911x.h~smc911x-remove-unused-8-bit-i-o-operations drivers/net/smc911x.h
--- a/drivers/net/smc911x.h~smc911x-remove-unused-8-bit-i-o-operations
+++ a/drivers/net/smc911x.h
@@ -50,10 +50,8 @@
  */
 
 #if	SMC_USE_16BIT
-#define SMC_inb(a, r)			 readb((a) + (r))
 #define SMC_inw(a, r)			 readw((a) + (r))
 #define SMC_inl(a, r)			 ((SMC_inw(a, r) & 0xFFFF)+(SMC_inw(a+2, r)<<16))
-#define SMC_outb(v, a, r)		 writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)		 writew(v, (a) + (r))
 #define SMC_outl(v, a, r) 			 \
 	do{					 \
@@ -64,10 +62,8 @@
 #define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
-#define SMC_inb(a, r)		 readb((a) + (r))
 #define SMC_inw(a, r)		 readw((a) + (r))
 #define SMC_inl(a, r)		 readl((a) + (r))
-#define SMC_outb(v, a, r)	 writeb(v, (a) + (r))
 #define SMC_outl(v, a, r)	 writel(v, (a) + (r))
 #define SMC_insl(a, r, p, l)	 readsl((int*)((a) + (r)), p, l)
 #define SMC_outsl(a, r, p, l)	 writesl((int*)((a) + (r)), p, l)
_
