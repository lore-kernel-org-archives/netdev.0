From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 8/8] sky2: fragmented receive for large MTU
Date: Tue, 26 Sep 2006 16:16:38 -0700
Message-ID: <20060926161638.28d1b2ea@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45747 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965139AbWIZXRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHJnW026374
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHIT4006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:19 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Version 1.9 is for 2.6.19.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:26.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:28.000000000 -0700
@@ -50,7 +50,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.7"
+#define DRV_VERSION		"1.9"
 #define PFX			DRV_NAME " "
 
 /*
