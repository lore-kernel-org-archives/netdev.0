From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] pasemi_mac: fix typo
Date: Sat, 20 Oct 2007 14:10:03 -0500
Message-ID: <20071020191003.GB30034@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:37495 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757729AbXJTTDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 15:03:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing &:

drivers/net/pasemi_mac.c: In function 'pasemi_mac_clean_rx':
drivers/net/pasemi_mac.c:553: warning: passing argument 1 of 'prefetch'
makes pointer from integer without a cast


Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 9f9a421..ab4d309 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -550,7 +550,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 
 	n = mac->rx->next_to_clean;
 
-	prefetch(RX_RING(mac, n));
+	prefetch(&RX_RING(mac, n));
 
 	for (count = 0; count < limit; count++) {
 		macrx = RX_RING(mac, n);
