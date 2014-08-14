From: Andreas Ruprecht <rupran@einserver.de>
Subject: [PATCH] net: ethernet: ibm: ehea: Remove duplicate object from Makefile
Date: Thu, 14 Aug 2014 14:26:23 +0200
Message-ID: <1408019183-5709-1-git-send-email-rupran@einserver.de>
Cc: netdev@vger.kernel.org, Andreas Ruprecht <rupran@einserver.de>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:44012 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbaHNM0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:26:13 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so922484lab.21
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 05:26:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the Makefile, ehea_phyp.o is included twice in the list of
object files compile into ehea.o.

This change removes one instance.

Signed-off-by: Andreas Ruprecht <rupran@einserver.de>
---
 drivers/net/ethernet/ibm/ehea/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/Makefile b/drivers/net/ethernet/ibm/ehea/Makefile
index 775d996..cd473e2 100644
--- a/drivers/net/ethernet/ibm/ehea/Makefile
+++ b/drivers/net/ethernet/ibm/ehea/Makefile
@@ -1,6 +1,6 @@
 #
 # Makefile for the eHEA ethernet device driver for IBM eServer System p
 #
-ehea-y = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+ehea-y = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o
 obj-$(CONFIG_EHEA) += ehea.o
 
-- 
1.9.1
