From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] ibm emac: delete module references; phy.c only supported as built-in
Date: Mon, 27 Feb 2012 14:47:04 -0500
Message-ID: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org,
	jwboyer@gmail.com, mporter@kernel.crashing.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40584 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab2B0TrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 14:47:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Makefile has it as "ibm_emac-y := mal.o core.o phy.o" so there is
no way this can be built modular, so remove all references to module
support.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
index d3b9d10..fb96387 100644
--- a/drivers/net/ethernet/ibm/emac/phy.c
+++ b/drivers/net/ethernet/ibm/emac/phy.c
@@ -11,13 +11,15 @@
  * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
  *                <benh@kernel.crashing.org>
  *
+ * Originally listed as MODULE_LICENSE("GPL") in the code, but that
+ * was removed, since this code is only supported as non-modular.
+ *
  * Based on the arch/ppc version of the driver:
  *
  * (c) 2003, Benjamin Herrenscmidt (benh@kernel.crashing.org)
  * (c) 2004-2005, Eugene Surovegin <ebs@ebshome.net>
  *
  */
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
@@ -537,5 +539,3 @@ int emac_mii_phy_probe(struct mii_phy *phy, int address)
 
 	return 0;
 }
-
-MODULE_LICENSE("GPL");
-- 
1.7.9.1
