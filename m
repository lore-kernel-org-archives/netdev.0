From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 1/3 net-next v3] net: ethtool: disambiguate XCVR_*
 meaning
Date: Thu, 23 May 2013 12:11:11 +0100
Message-ID: <1369307473-20696-2-git-send-email-f.fainelli@gmail.com>
References: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	bhutchings@solarflare.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3161 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758176Ab3EWLeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 07:34:16 -0400
In-Reply-To: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a comment which explains the real meaning of XCVR_INTERNAL (PHY and
Ethernet MAC in the same package/die) and XCVR_EXTERNAL (PHY and
Ethernet MAC in a different package/die). Most if not all of the drivers
setting their transceiver type already do it the way the comment
describes it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/uapi/linux/ethtool.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 0c9b448..38dbafa 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -993,8 +993,8 @@ enum ethtool_sfeatures_retval_bits {
 #define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
-#define XCVR_INTERNAL		0x00
-#define XCVR_EXTERNAL		0x01
+#define XCVR_INTERNAL		0x00 /* PHY and MAC are in the same package */
+#define XCVR_EXTERNAL		0x01 /* PHY and MAC are in different packages */
 #define XCVR_DUMMY1		0x02
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
-- 
1.8.1.2
