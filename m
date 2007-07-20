From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 4/10] ps3: removed defines no longer used
Date: Fri, 20 Jul 2007 17:27:12 +0900
Message-ID: <20070720172518.6792.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NS5.Sony.CO.JP ([137.153.0.45]:48030 "EHLO ns5.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932380AbXGTI1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed defines no longer used.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.h |    7 -------
 1 file changed, 7 deletions(-)

--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -28,15 +28,8 @@
 #ifndef _GELIC_NET_H
 #define _GELIC_NET_H
 
-#define GELIC_NET_DRV_NAME "Gelic Network Driver"
-#define GELIC_NET_DRV_VERSION "1.0"
-
 #define GELIC_NET_ETHTOOL               /* use ethtool */
 
-/* ioctl */
-#define GELIC_NET_GET_MODE              (SIOCDEVPRIVATE + 0)
-#define GELIC_NET_SET_MODE              (SIOCDEVPRIVATE + 1)
-
 /* descriptors */
 #define GELIC_NET_RX_DESCRIPTORS        128 /* num of descriptors */
 #define GELIC_NET_TX_DESCRIPTORS        128 /* num of descriptors */

--
Masakazu MOKUNO

