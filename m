From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH] fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register
Date: Tue, 7 Jul 2009 11:23:34 +1000
Message-ID: <200907070123.n671NY36005818@localhost.localdomain>
Cc: gerg@uclinux.org, s.hauer@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:55339 "EHLO
	snapgear.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752967AbZGGBXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 21:23:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register

The ColdFire 5272 FEC driver has a different register address map
than other users of the FEC driver. And its definition of the
FEC_X_DES_ACTIVE register is incorrect, it should be 0x14.
The fec interface cannot transmit data with the old value.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
----

diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 6958d85..cc47f3f 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -51,7 +51,7 @@
 #define FEC_IMASK		0x008 /* Interrupt mask reg */
 #define FEC_IVEC		0x00c /* Interrupt vec status reg */
 #define FEC_R_DES_ACTIVE	0x010 /* Receive descriptor reg */
-#define FEC_X_DES_ACTIVE	0x01c /* Transmit descriptor reg */
+#define FEC_X_DES_ACTIVE	0x014 /* Transmit descriptor reg */
 #define FEC_MII_DATA		0x040 /* MII manage frame reg */
 #define FEC_MII_SPEED		0x044 /* MII speed control reg */
 #define FEC_R_BOUND		0x08c /* FIFO receive bound reg */
