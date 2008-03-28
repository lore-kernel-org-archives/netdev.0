From: akpm@linux-foundation.org
Subject: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized var warning
Date: Fri, 28 Mar 2008 14:37:29 -0700
Message-ID: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	chas@cmf.nrl.navy.mil, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59710 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755945AbYC1ViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/atm/firestream.c: In function 'fs_open':
drivers/atm/firestream.c:870: warning: 'tmc0' may be used uninitialized in this function

I have confirmed that this is a false positive.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/firestream.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/atm/firestream.c~drivers-atm-firestreamc-suppress-uninitialized-var-warning drivers/atm/firestream.c
--- a/drivers/atm/firestream.c~drivers-atm-firestreamc-suppress-uninitialized-var-warning
+++ a/drivers/atm/firestream.c
@@ -867,7 +867,7 @@ static int fs_open(struct atm_vcc *atm_v
 	int error;
 	int bfp;
 	int to;
-	unsigned short tmc0;
+	unsigned short uninitialized_var(tmc0);
 	short vpi = atm_vcc->vpi;
 	int vci = atm_vcc->vci;
 
_
