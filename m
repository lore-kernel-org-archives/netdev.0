From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atlx: duplicate testing of MCAST flag
Date: Mon, 13 Jul 2009 01:12:37 +0200
Message-ID: <4A5A6DE5.4090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: jcliburn@gmail.com, atl1-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:61194 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbZGLXLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 19:11:11 -0400
Received: by ewy26 with SMTP id 26so2212354ewy.37
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 16:11:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix duplicate testing of MCAST flag

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
I think the first should be UCAST, correct?

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index c734b19..204db96 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -2071,7 +2071,7 @@ static int atl2_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 
-	if (wol->wolopts & (WAKE_MCAST|WAKE_BCAST|WAKE_MCAST))
+	if (wol->wolopts & (WAKE_UCAST | WAKE_BCAST | WAKE_MCAST))
 		return -EOPNOTSUPP;
 
 	/* these settings will always override what we currently have */
