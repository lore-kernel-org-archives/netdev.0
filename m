From: akpm@linux-foundation.org
Subject: [patch 3/4] atl1c: WAKE_MCAST tested twice, not WAKE_UCAST
Date: Wed, 10 Jun 2009 12:55:03 -0700
Message-ID: <200906101955.n5AJt3nD008241@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com, csnook@redhat.com, jcliburn@gmail.com,
	jie.yang@atheros.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36220 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758305AbZFJTzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The WAKE_MCAST bit is tested twice, the first should be WAKE_UCAST.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Jie Yang <jie.yang@atheros.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <csnook@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atl1c/atl1c_ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/atl1c/atl1c_ethtool.c~atl1c-wake_mcast-tested-twice-not-wake_ucast drivers/net/atl1c/atl1c_ethtool.c
--- a/drivers/net/atl1c/atl1c_ethtool.c~atl1c-wake_mcast-tested-twice-not-wake_ucast
+++ a/drivers/net/atl1c/atl1c_ethtool.c
@@ -271,7 +271,7 @@ static int atl1c_set_wol(struct net_devi
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
-			    WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
+			    WAKE_UCAST | WAKE_BCAST | WAKE_MCAST))
 		return -EOPNOTSUPP;
 	/* these settings will always override what we currently have */
 	adapter->wol = 0;
_
