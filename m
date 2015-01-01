From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: fddi: skfp: smt.c:  Remove unused function
Date: Thu,  1 Jan 2015 18:01:26 +0100
Message-ID: <1420131686-30895-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:57494 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbbAAQ60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 11:58:26 -0500
Received: by mail-wg0-f50.google.com with SMTP id a1so23419537wgh.9
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 08:58:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the function smt_ifconfig() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/fddi/skfp/smt.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/fddi/skfp/smt.c b/drivers/net/fddi/skfp/smt.c
index 9edada8..cd78b7c 100644
--- a/drivers/net/fddi/skfp/smt.c
+++ b/drivers/net/fddi/skfp/smt.c
@@ -1736,18 +1736,6 @@ char *addr_to_string(struct fddi_addr *addr)
 }
 #endif
 
-#ifdef	AM29K
-int smt_ifconfig(int argc, char *argv[])
-{
-	if (argc >= 2 && !strcmp(argv[0],"opt_bypass") &&
-	    !strcmp(argv[1],"yes")) {
-		smc->mib.fddiSMTBypassPresent = 1 ;
-		return 0;
-	}
-	return amdfddi_config(0, argc, argv);
-}
-#endif
-
 /*
  * return static mac index
  */
-- 
1.7.10.4
