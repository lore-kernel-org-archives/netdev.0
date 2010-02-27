From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/9] Bluetooth: Add __init/__exit macros to Marvell SDIO driver
Date: Sat, 27 Feb 2010 23:38:30 +0100
Message-ID: <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54687 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936346Ab0B0WkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:17 -0500
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <peterhuewe@gmx.de>

Trivial patch which adds the __init/__exit macros to the module_init/
module_exit functions of btmrvl_sdio.c driver.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_sdio.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 57d965b..94f1f55 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -976,7 +976,7 @@ static struct sdio_driver bt_mrvl_sdio = {
 	.remove		= btmrvl_sdio_remove,
 };
 
-static int btmrvl_sdio_init_module(void)
+static int __init btmrvl_sdio_init_module(void)
 {
 	if (sdio_register_driver(&bt_mrvl_sdio) != 0) {
 		BT_ERR("SDIO Driver Registration Failed");
@@ -989,7 +989,7 @@ static int btmrvl_sdio_init_module(void)
 	return 0;
 }
 
-static void btmrvl_sdio_exit_module(void)
+static void __exit btmrvl_sdio_exit_module(void)
 {
 	/* Set the flag as user is removing this module. */
 	user_rmmod = 1;
-- 
1.6.6

