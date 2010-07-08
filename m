From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 02/13] Bluetooth: Remove L2CAP Extended Features from Kconfig
Date: Thu,  8 Jul 2010 16:59:51 -0300
Message-ID: <f681fb7be711495fab80ad7ef22ad672d40b484b.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36213 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:30 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

This reverts commit 84fb0a6334af0ccad3544f6972c055d90fbb9fbe which adds
the L2CAP Extended Features to the Kconfig, that is actually not needed.
One can use other mechanisms to enable L2CAP Extended Features.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/Kconfig |   13 -------------
 net/bluetooth/l2cap.c |    4 ----
 2 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index ee3b304..ed37168 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -43,19 +43,6 @@ config BT_L2CAP
 	  Say Y here to compile L2CAP support into the kernel or say M to
 	  compile it as module (l2cap).
 
-config BT_L2CAP_EXT_FEATURES
-	bool "L2CAP Extended Features support (EXPERIMENTAL)"
-	depends on BT_L2CAP && EXPERIMENTAL
-	help
-	  This option enables the L2CAP Extended Features support. These
-	  new features include the Enhanced Retransmission and Streaming
-	  Modes, the Frame Check Sequence (FCS), and Segmentation and
-	  Reassembly (SAR) for L2CAP packets. They are a required for the
-	  new Alternate MAC/PHY and the Bluetooth Medical Profile.
-
-	  You should say N unless you know what you are doing. Note that
-	  this is in an experimental state yet.
-
 config BT_SCO
 	tristate "SCO links support"
 	depends on BT
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 5c636b3..e036419 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -55,11 +55,7 @@
 
 #define VERSION "2.14"
 
-#ifdef CONFIG_BT_L2CAP_EXT_FEATURES
-static int enable_ertm = 1;
-#else
 static int enable_ertm = 0;
-#endif
 
 static u32 l2cap_feat_mask = L2CAP_FEAT_FIXED_CHAN;
 static u8 l2cap_fixed_chan[8] = { 0x02, };
-- 
1.7.1.1

