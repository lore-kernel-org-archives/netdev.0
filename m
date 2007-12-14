From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [ROSE] static const struct proto_ops in af_rose.c
Date: Fri, 14 Dec 2007 23:33:41 +0100
Message-ID: <476304C5.5030805@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070104000609000109050508"
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:48184 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758655AbXLNWxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:53:21 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix1-g20.free.fr (Postfix) with ESMTP id CFDA62030286
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 23:53:20 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070104000609000109050508
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch corrects the declaration of struct proto_ops as static const 
like in struct socket <linux/net.h>

signed off by Bernard Pidoux, f6bvp@amsat.org

--------------070104000609000109050508
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch4"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch4"

--- linux-2.6.24-rc5/net/rose/af_rose.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/af_rose.c	2007-12-14 14:32:06.000000000 +0100
@@ -63,7 +63,7 @@
 static HLIST_HEAD(rose_list);
 static DEFINE_SPINLOCK(rose_list_lock);
 
-static struct proto_ops rose_proto_ops;
+static const struct proto_ops rose_proto_ops;
 
 ax25_address rose_callsign;
 
@@ -1483,7 +1483,7 @@
 	.owner		=	THIS_MODULE,
 };
 
-static struct proto_ops rose_proto_ops = {
+static const struct proto_ops rose_proto_ops = {
 	.family		=	PF_ROSE,
 	.owner		=	THIS_MODULE,
 	.release	=	rose_release,

--------------070104000609000109050508--

