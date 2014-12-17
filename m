From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 05/10] veth: Enable UFO6 support.
Date: Wed, 17 Dec 2014 13:20:50 -0500
Message-ID: <1418840455-22598-6-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:65021 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaLQSVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:24 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so12430304qcx.16
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:22 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn on UFO6 feature.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/veth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8ad5965..0052db5 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -280,7 +280,7 @@ static const struct net_device_ops veth_netdev_ops = {
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
 		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
 		       NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |	    \
-		       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT | NETIF_F_UFO	|   \
+		       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT | NETIF_F_ALL_UFO | \
 		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
 		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
 
-- 
1.9.3
