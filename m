From: John Faith <jfaith7@gmail.com>
Subject: [PATCH] smsc911x: Set Ethernet EEPROM size to supported device's size
Date: Mon,  1 Nov 2010 14:30:08 -0700
Message-ID: <1288647008-11846-1-git-send-email-jfaith7@gmail.com>
Cc: linux-omap@vger.kernel.org, John Faith <jfaith7@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:58139 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab0KAVbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMSC911x supports 128 x 8-bit EEPROMs.  Increase the EEPROM size
so more than just the MAC address can be stored.

Signed-off-by: John Faith <jfaith7@gmail.com>
---
 drivers/net/smsc911x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index 016360c..8a79585 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -22,7 +22,7 @@
 #define __SMSC911X_H__
 
 #define TX_FIFO_LOW_THRESHOLD	((u32)1600)
-#define SMSC911X_EEPROM_SIZE	((u32)7)
+#define SMSC911X_EEPROM_SIZE	((u32)128)
 #define USE_DEBUG		0
 
 /* This is the maximum number of packets to be received every
-- 
1.7.0.4

