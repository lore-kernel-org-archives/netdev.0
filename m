From: Parav Pandit <Parav.pandit@avagotech.com>
Subject: [PATCH] ethtool: Added additional port speed macros.
Date: Mon, 18 May 2015 16:32:43 +0530
Message-ID: <1431946963-7852-1-git-send-email-Parav.pandit@avagotech.com>
Cc: bwh@kernel.org, davem@davemloft.net, parav.pandit@avagotech.com,
	Parav Pandit <Parav.pandit@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56696 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751223AbbERFb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 01:31:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Parav Pandit <Parav.pandit@avagotech.com>
---
 ethtool-copy.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..620dbcd 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
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
