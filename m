From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] ucc_geth: remove unnecessary asm/ocp.h include from ucc_geth_mii.c
Date: Wed, 19 Sep 2007 10:30:44 -0500
Message-ID: <11902158442710-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:36896 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbXISPay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:30:54 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l8JFUlEZ024613
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 08:30:52 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ucc_geth_mii.c includes <asm/ocp.h>, but it never needed it.  With commit
2f6c9d961081dc7b109eb19166244bcb2a5dfc28, the asm-powerpc => asm-ppc link
is removed, and so ucc_geth_mii.c can no longer include include/asm-ppc/ocp.h,
so the compile fails.  This patch removes the #include line.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

This patch is for the net-2.6.24 branch of the netdev-2.6.git repository.

 drivers/net/ucc_geth_mii.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 6c257b8..df884f0 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -32,7 +32,6 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <asm/ocp.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
-- 
1.5.2.4

