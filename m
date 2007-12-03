From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 5/5] [IrDA] irda parameters warning fixes.
Date: Mon, 03 Dec 2007 10:28:36 +0100
Message-ID: <20071203093053.944365836@sortiz.org>
References: <20071203092831.724254969@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	Richard Knutsson <ricknu-0@student.ltu.se>,
	Andrew Morton <akpm@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.31]:54509 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbXLCB3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 20:29:08 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2022.orange.fr (SMTP Server) with ESMTP id 425ED1C00088
	for <netdev@vger.kernel.org>; Mon,  3 Dec 2007 02:29:05 +0100 (CET)
Content-Disposition: inline; filename=irda_parameters.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes:
  CHECK   /home/kernel/src/net/irda/parameters.c
/home/kernel/src/net/irda/parameters.c:466:2: warning: Using plain integer as NULL pointer
/home/kernel/src/net/irda/parameters.c:520:2: warning: Using plain integer as NULL pointer
/home/kernel/src/net/irda/parameters.c:573:2: warning: Using plain integer as NULL pointer

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 net/irda/parameters.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6/net/irda/parameters.c
===================================================================
--- net-2.6.orig/net/irda/parameters.c	2007-11-25 05:54:02.000000000 +0100
+++ net-2.6/net/irda/parameters.c	2007-11-26 10:20:38.000000000 +0100
@@ -463,7 +463,7 @@
 	int n = 0;
 
 	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != 0, return ret;);
+	IRDA_ASSERT(info != NULL, return ret;);
 
 	pi_minor = pi & info->pi_mask;
 	pi_major = pi >> info->pi_major_offset;
@@ -517,7 +517,7 @@
 	int n = 0;
 
 	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != 0, return ret;);
+	IRDA_ASSERT(info != NULL, return ret;);
 
 	pi_minor = buf[n] & info->pi_mask;
 	pi_major = buf[n] >> info->pi_major_offset;
@@ -570,7 +570,7 @@
 	int n = 0;
 
 	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != 0, return ret;);
+	IRDA_ASSERT(info != NULL, return ret;);
 
 	/*
 	 * Parse all parameters. Each parameter must be at least two bytes

-- 

