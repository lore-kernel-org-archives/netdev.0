From: Nik Nyby <nikolas@gnu.org>
Subject: [PATCH] sis900: Trivial: Fix typos in enums
Date: Mon, 29 Jun 2015 15:49:43 -0400
Message-ID: <1435607383-12162-1-git-send-email-nikolas@gnu.org>
Cc: Nik Nyby <nikolas@gnu.org>
To: venza@brownhat.org, netdev@vger.kernel.org, trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eggs.gnu.org ([208.118.235.92]:42012 "EHLO eggs.gnu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064AbbF2TuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 15:50:03 -0400
Received: from Debian-exim by eggs.gnu.org with spam-scanned (Exim 4.71)
	(envelope-from <nikolas@gnu.org>)
	id 1Z9f45-0007YI-MG
	for netdev@vger.kernel.org; Mon, 29 Jun 2015 15:50:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"reigster" -> "register"

Signed-off-by: Nik Nyby <nikolas@gnu.org>
---
 drivers/net/ethernet/sis/sis900.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.h b/drivers/net/ethernet/sis/sis900.h
index 1341f33..7d430d3 100644
--- a/drivers/net/ethernet/sis/sis900.h
+++ b/drivers/net/ethernet/sis/sis900.h
@@ -56,7 +56,7 @@ enum sis900_configuration_register_bits {
 	EDB_MASTER_EN = 0x00002000
 };
 
-enum sis900_eeprom_access_reigster_bits {
+enum sis900_eeprom_access_register_bits {
 	MDC  = 0x00000040, MDDIR = 0x00000020, MDIO = 0x00000010, /* 7016 specific */
 	EECS = 0x00000008, EECLK = 0x00000004, EEDO = 0x00000002,
 	EEDI = 0x00000001
@@ -73,7 +73,7 @@ enum sis900_interrupt_register_bits {
 	RxERR  = 0x00000004, RxDESC = 0x00000002, RxOK  = 0x00000001
 };
 
-enum sis900_interrupt_enable_reigster_bits {
+enum sis900_interrupt_enable_register_bits {
 	IE = 0x00000001
 };
 
-- 
2.1.4
