From: akpm@osdl.org
Subject: [patch 4/6] IRDA: add some IBM think pads
Date: Sun, 25 Jun 2006 01:47:31 -0700
Message-ID: <200606250847.k5P8lVUm020906@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bcollins@ubuntu.com,
	randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15507 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751169AbWFYIrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 04:47:37 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ben Collins <bcollins@ubuntu.com>

[UBUNTU:nsc-ircc] Add some IBM think pads
Add Thinkpad T60/X60/Z60/T43/R52 Infrared driver support.

http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=7b8d2713435a9fb69719a282ba75e117f3f76a5b

Cc: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Ben Collins <bcollins@ubuntu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/irda/nsc-ircc.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/nsc-ircc.c~irda-add-some-ibm-think-pads drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c~irda-add-some-ibm-think-pads
+++ a/drivers/net/irda/nsc-ircc.c
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
 
_
