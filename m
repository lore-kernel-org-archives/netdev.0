From: John Crispin <blogic@openwrt.org>
Subject: [PATCH] NET: MIPS: lantiq: fix etop compile error
Date: Mon, 14 Nov 2011 16:01:18 +0100
Message-ID: <1321282878-29372-1-git-send-email-blogic@openwrt.org>
Cc: John Crispin <blogic@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60108 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1KNOBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 09:01:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Lantiq ETOP ethernet driver fails to build in 3.2-rc1 due to 2 missing
header files.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/lantiq_etop.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 6bb2b95..0b3567a 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -34,6 +34,8 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/io.h>
+#include <linux/dma-mapping.h>
+#include <linux/module.h>
 
 #include <asm/checksum.h>
 
-- 
1.7.7.1
