From: akpm@osdl.org
Subject: [patch 3/5] ATM: he: fix section mismatch
Date: Tue, 19 Sep 2006 18:08:50 -0700
Message-ID: <200609200108.k8K18oW2011719@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55696 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750813AbWITBIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 21:08:53 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

WARNING: drivers/atm/he.o - Section mismatch: reference to .init.text: from .text between 'he_start' (at offset 0x218a) and 'he_service_tbrq'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/atm/he.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/atm/he.c~atm-he-fix-section-mismatch drivers/atm/he.c
--- a/drivers/atm/he.c~atm-he-fix-section-mismatch
+++ a/drivers/atm/he.c
@@ -785,7 +785,7 @@ he_init_cs_block_rcm(struct he_dev *he_d
 	return 0;
 }
 
-static int __init
+static int __devinit
 he_init_group(struct he_dev *he_dev, int group)
 {
 	int i;
_
