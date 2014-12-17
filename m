From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 06/10] macvlan: Enable UFO6 support.
Date: Wed, 17 Dec 2014 13:20:51 -0500
Message-ID: <1418840455-22598-7-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:43856 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaLQSVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:24 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so12256784qge.18
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:24 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn on UFO6 feature.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index bfb0b6e..807b98d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -746,7 +746,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_ALL_UFO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
-- 
1.9.3
