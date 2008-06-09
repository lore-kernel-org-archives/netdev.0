From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make drivers/net/atarilance.c:lance_addr_list[] static
Date: Tue, 10 Jun 2008 01:23:29 +0300
Message-ID: <20080609222329.GO1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41007 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759989AbYFIWYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:24:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global lance_addr_list[] static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- linux-2.6/drivers/net/atarilance.c.old	2008-06-09 00:54:46.000000000 +0300
+++ linux-2.6/drivers/net/atarilance.c	2008-06-09 00:54:54.000000000 +0300
@@ -242,9 +242,9 @@ struct lance_private {
 #define	PKTBUF_ADDR(head)	(((unsigned char *)(MEM)) + (head)->base)
 
 /* Possible memory/IO addresses for probing */
 
-struct lance_addr {
+static struct lance_addr {
 	unsigned long	memaddr;
 	unsigned long	ioaddr;
 	int				slow_flag;
 } lance_addr_list[] = {

