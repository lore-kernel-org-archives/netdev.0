From: Parav Pandit <parav.pandit@avagotech.com>
Subject: [PATCH] net-next: ethtool: Added port speed macros.
Date: Mon, 18 May 2015 16:31:47 +0530
Message-ID: <1431946907-7808-1-git-send-email-parav.pandit@avagotech.com>
Cc: bwh@kernel.org, davem@davemloft.net, parav.pandit@avagotech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56686 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751214AbbERFaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 01:30:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Parav Pandit <parav.pandit@avagotech.com>
---
 include/uapi/linux/ethtool.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 2e49fc8..ae832b4 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1264,15 +1264,19 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
+/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|5|10|20|25|40|50|56|100]GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
 #define SPEED_2500		2500
+#define SPEED_5000		5000
 #define SPEED_10000		10000
 #define SPEED_20000		20000
+#define SPEED_25000		25000
 #define SPEED_40000		40000
+#define SPEED_50000		50000
 #define SPEED_56000		56000
+#define SPEED_100000		100000
 
 #define SPEED_UNKNOWN		-1
 
-- 
1.7.1
