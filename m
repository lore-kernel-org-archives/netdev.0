From: akpm@linux-foundation.org
Subject: [patch 1/3] git-net: make it compile (not for applying?)
Date: Tue, 02 Oct 2007 14:04:37 -0700
Message-ID: <200710022104.l92L4cuE022227@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063AbXJBVFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/hamradio/baycom_epp.c: In function 'baycom_probe':
drivers/net/hamradio/baycom_epp.c:1162: error: 'struct net_device' has no member named 'hard_header'
drivers/net/hamradio/baycom_epp.c:1163: error: 'struct net_device' has no member named 'rebuild_header'

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/baycom_epp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/hamradio/baycom_epp.c~git-net-more-bustage drivers/net/hamradio/baycom_epp.c
--- a/drivers/net/hamradio/baycom_epp.c~git-net-more-bustage
+++ a/drivers/net/hamradio/baycom_epp.c
@@ -1159,8 +1159,8 @@ static void baycom_probe(struct net_devi
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
-	dev->hard_header = ax25_hard_header;
-	dev->rebuild_header = ax25_rebuild_header;
+//	dev->hard_header = ax25_hard_header;
+//	dev->rebuild_header = ax25_rebuild_header;
 	dev->set_mac_address = baycom_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
_
