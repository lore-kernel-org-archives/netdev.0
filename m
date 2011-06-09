From: Yegor Yefremov <yegor_sub1@visionsystems.de>
Subject: [PATCH]ethtool.h: fix typos
Date: Thu, 09 Jun 2011 09:39:18 +0200
Message-ID: <4DF078A6.4090200@visionsystems.de>
Reply-To: yegor_sub1@visionsystems.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.vscom.de ([62.145.30.242]:54678 "EHLO mail.visionsystems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619Ab1FIH5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 03:57:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

---
 include/linux/ethtool.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: b/include/linux/ethtool.h
===================================================================
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -268,7 +268,7 @@
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
 
 	/* If the link is being auto-negotiated (via ethtool_cmd.autoneg
-	 * being true) the user may set 'autonet' here non-zero to have the
+	 * being true) the user may set 'autoneg' here non-zero to have the
 	 * pause parameters be auto-negotiated too.  In such a case, the
 	 * {rx,tx}_pause values below determine what capabilities are
 	 * advertised.
@@ -811,7 +811,7 @@
  * @get_tx_csum: Deprecated as redundant. Report whether transmit checksums
  *	are turned on or off.
  * @set_tx_csum: Deprecated in favour of generic netdev features.  Turn
- *	transmit checksums on or off.  Returns a egative error code or zero.
+ *	transmit checksums on or off.  Returns a negative error code or zero.
  * @get_sg: Deprecated as redundant.  Report whether scatter-gather is
  *	enabled.  
  * @set_sg: Deprecated in favour of generic netdev features.  Turn
@@ -1087,7 +1087,7 @@
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
  * devices settings, these indicate the current mode and whether
- * it was foced up into this mode or autonegotiated.
+ * it was forced up into this mode or autonegotiated.
  */
 
 /* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */

