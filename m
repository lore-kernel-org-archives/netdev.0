From: "Michael Chan" <mchan@broadcom.com>
Subject: [ETHTOOL]: Add 2.5G bit definitions.
Date: Thu, 03 May 2007 00:25:51 -0700
Message-ID: <1178177151.4909.62.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2108 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbXECGis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:38:48 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ETHTOOL]: Add 2.5G bit definitions.

Add 2.5G supported and advertising bit definitions.  2.5G is supported
by the bnx2 driver.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6310ae..f2d248f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -434,6 +434,7 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseT_Full	(1 << 12)
 #define SUPPORTED_Pause			(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
+#define SUPPORTED_2500baseX_Full	(1 << 15)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -451,6 +452,7 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseT_Full	(1 << 12)
 #define ADVERTISED_Pause		(1 << 13)
 #define ADVERTISED_Asym_Pause		(1 << 14)
+#define ADVERTISED_2500baseX_Full	(1 << 15)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the


