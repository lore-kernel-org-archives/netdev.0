From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH] fec: remove extra ";" from definition names
Date: Tue, 7 Jul 2009 09:28:34 +1000
Message-ID: <200907062328.n66NSYmn008147@localhost.localdomain>
Cc: gerg@uclinux.org, s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:51737 "EHLO
	snapgear.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752868AbZGFX3C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 19:29:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec: remove extra ";" from definition names
    
Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---

diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 30b7dd6..6958d85 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -46,12 +46,12 @@
 
 #else
 
-#define FEC_ECNTRL;		0x000 /* Ethernet control reg */
-#define FEC_IEVENT;		0x004 /* Interrupt even reg */
-#define FEC_IMASK;		0x008 /* Interrupt mask reg */
-#define FEC_IVEC;		0x00c /* Interrupt vec status reg */
-#define FEC_R_DES_ACTIVE;	0x010 /* Receive descriptor reg */
-#define FEC_X_DES_ACTIVE;	0x01c /* Transmit descriptor reg */
+#define FEC_ECNTRL		0x000 /* Ethernet control reg */
+#define FEC_IEVENT		0x004 /* Interrupt even reg */
+#define FEC_IMASK		0x008 /* Interrupt mask reg */
+#define FEC_IVEC		0x00c /* Interrupt vec status reg */
+#define FEC_R_DES_ACTIVE	0x010 /* Receive descriptor reg */
+#define FEC_X_DES_ACTIVE	0x01c /* Transmit descriptor reg */
 #define FEC_MII_DATA		0x040 /* MII manage frame reg */
 #define FEC_MII_SPEED		0x044 /* MII speed control reg */
 #define FEC_R_BOUND		0x08c /* FIFO receive bound reg */
