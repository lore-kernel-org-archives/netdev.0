From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next] ethtool: Add 20G bit definitions
Date: Tue, 3 May 2011 10:30:08 +0300
Message-ID: <1304407809.2518.1.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4860 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852Ab1ECHa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 03:30:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 20G supported and advertising bit definitions.
20G will be supported with the 57840 chips.


Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
------
 include/linux/ethtool.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9de3127..620a96a 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -1024,6 +1024,8 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseKX4_Full	(1 << 18)
 #define SUPPORTED_10000baseKR_Full	(1 << 19)
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
+#define SUPPORTED_20000baseMLD2_Full	(1 << 21)
+#define SUPPORTED_20000baseKR2_Full	(1 << 22)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -1047,6 +1049,8 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseKX4_Full	(1 << 18)
 #define ADVERTISED_10000baseKR_Full	(1 << 19)
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
+#define ADVERTISED_20000baseMLD2_Full	(1 << 21)
+#define ADVERTISED_20000baseKR2_Full	(1 << 22)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
-- 
1.7.1






