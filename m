From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [Ubuntu PATCH] IRDA: Add some IBM think pads
Date: Wed, 14 Jun 2006 16:23:28 -0700
Message-ID: <44909A70.7070104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@osdl.org>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:49214 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S964772AbWFNWXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:23:00 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Collins <bcollins@ubuntu.com>

[UBUNTU:nsc-ircc] Add some IBM think pads
Add Thinkpad T60/X60/Z60/T43/R52 Infrared driver support.

http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=7b8d2713435a9fb69719a282ba75e117f3f76a5b

Signed-off-by: Ben Collins <bcollins@ubuntu.com>
---

--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -115,8 +115,12 @@ static nsc_chip_t chips[] = {
 	/* Contributed by Jan Frey - IBM A30/A31 */
 	{ "PC8739x", { 0x2e, 0x4e, 0x0 }, 0x20, 0xea, 0xff, 
 	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
-	{ "IBM", { 0x2e, 0x4e, 0x0 }, 0x20, 0xf4, 0xff,
- 	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
+	/* IBM ThinkPads using PC8738x (T60/X60/Z60) */
+	{ "IBM-PC8738x", { 0x2e, 0x4e, 0x0 }, 0x20, 0xf4, 0xff,
+	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
+	/* IBM ThinkPads using PC8394T (T43/R52/?) */
+	{ "IBM-PC8394T", { 0x2e, 0x4e, 0x0 }, 0x20, 0xf9, 0xff,
+	  nsc_ircc_probe_39x, nsc_ircc_init_39x },
 	{ NULL }
 };

