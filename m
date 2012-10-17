From: Grzegorz Chmurzynski <chmurzynski@kei.pl>
Subject: Missing or wrong firmware file bnx2 driver
Date: Wed, 17 Oct 2012 07:34:53 +0200
Message-ID: <507E437D.5010408@kei.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.kei.pl ([195.149.224.45]:50232 "EHLO smtp.kei.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab2JQFlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 01:41:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that for a long time no valid driver file in the 3.x branch of kernel.

Patch:

diff -ruNp linux-3.4/drivers/net/ethernet/broadcom/bnx2.c linux-3.4p/drivers/net/ethernet/broadcom/bnx2.c
--- linux-3.4/drivers/net/ethernet/broadcom/bnx2.c 2012-09-12 19:08:37.000000000 +0200
+++ linux-3.4p/drivers/net/ethernet/broadcom/bnx2.c 2012-09-17 09:34:16.000000000 +0200
@@ -59,7 +59,7 @@
#define DRV_MODULE_NAME "bnx2"
#define DRV_MODULE_VERSION "2.2.1"
#define DRV_MODULE_RELDATE "Dec 18, 2011"
-#define FW_MIPS_FILE_06 "bnx2/bnx2-mips-06-6.2.3.fw"
+#define FW_MIPS_FILE_06 "bnx2/bnx2-mips-06-6.2.1.fw"
#define FW_RV2P_FILE_06 "bnx2/bnx2-rv2p-06-6.0.15.fw"
#define FW_MIPS_FILE_09 "bnx2/bnx2-mips-09-6.2.1b.fw"
#define FW_RV2P_FILE_09_Ax "bnx2/bnx2-rv2p-09ax-6.0.17.fw"

-- 
Pozdrawiam
Grzegorz Chmurzynski
