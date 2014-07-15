From: Sachin Kamat <sachin.kamat@samsung.com>
Subject: [PATCH 1/1] ethernet: mvpp2: Fix build breakage
Date: Tue, 15 Jul 2014 16:36:05 +0530
Message-ID: <1405422365-6214-1-git-send-email-sachin.kamat@samsung.com>
Cc: davem@davemloft.net, spk.linux@gmail.com,
	Marcin Wojtas <mw@semihalf.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:57417 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758738AbaGOLKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 07:10:04 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so4656809pdj.2
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 04:10:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A missing space in the module license string caused the following error
while doing a modular build.
FATAL: modpost: GPL-incompatible module mvpp2.ko uses GPL-only symbol 'platform_driver_unregister'

Signed-off-by: Sachin Kamat <sachin.kamat@samsung.com>
Cc: Marcin Wojtas <mw@semihalf.com>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9463ede32e6a..f4de2a9316ff 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6390,4 +6390,4 @@ module_platform_driver(mvpp2_driver);
 
 MODULE_DESCRIPTION("Marvell PPv2 Ethernet Driver - www.marvell.com");
 MODULE_AUTHOR("Marcin Wojtas <mw@semihalf.com>");
-MODULE_LICENSE("GPLv2");
+MODULE_LICENSE("GPL v2");
-- 
1.7.9.5
