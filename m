From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 01/05] smc911x: Remove unused 8-bit I/O operations
Date: Mon, 02 Jun 2008 20:37:14 +0900
Message-ID: <20080602113714.28716.10248.sendpatchset@rx1.opensource.se>
References: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	akpm@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:47685 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbYFBLhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 07:37:02 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1003094rvb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 04:37:01 -0700 (PDT)
In-Reply-To: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused SMC_inb() and SMC_outb() functions.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc911x.h |    4 ----
 1 file changed, 4 deletions(-)

--- 0001/drivers/net/smc911x.h
+++ work/drivers/net/smc911x.h	2008-06-02 12:23:49.000000000 +0900
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
