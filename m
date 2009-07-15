From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] gianfar: remove unused DECLARE_MAC_BUF
Date: Wed, 15 Jul 2009 17:18:59 +0200
Message-ID: <1247671139.10754.3.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46454 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208AbZGOP2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 11:28:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of it was converted to %pM, but the variable
stuck -- remove it now to not cause spurious warnings.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/gianfar.c |    1 -
 1 file changed, 1 deletion(-)

--- wireless-testing.orig/drivers/net/gianfar.c	2009-07-15 17:11:36.000000000 +0200
+++ wireless-testing/drivers/net/gianfar.c	2009-07-15 17:11:43.000000000 +0200
@@ -304,7 +304,6 @@ static int gfar_probe(struct of_device *
 	u32 tempval;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
-	DECLARE_MAC_BUF(mac);
 	int err = 0;
 	int len_devname;
 


