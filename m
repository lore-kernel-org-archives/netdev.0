From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] gianfar: kill unused header
Date: Fri, 13 Jul 2007 00:38:47 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0707130037570.16069@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42637 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbXGMFjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 01:39:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A long time ago we used OCP with the gianfar driver.  Eventually when
we kill arch/ppc including this will cause issues so lets just kill it now.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

---
commit 4e2440a284a0bfaaf3baa0ba4de2c2300912c983
tree cd40eeafcd71577c95dc775b2e682ed852db5f71
parent 773208946a132fb733ba273ee8562814f828cc28
author Kumar Gala <galak@kernel.crashing.org> Fri, 13 Jul 2007 00:37:49 -0500
committer Kumar Gala <galak@kernel.crashing.org> Fri, 13 Jul 2007 00:37:49 -0500

 drivers/net/gianfar_mii.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 5dd34a1..ac3596f 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -31,7 +31,6 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <asm/ocp.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
