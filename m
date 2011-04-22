From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: allow user to change NETIF_F_HIGHDMA
Date: Fri, 22 Apr 2011 18:31:16 +0200 (CEST)
Message-ID: <20110422163116.37DE613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53185 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110Ab1DVQbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 12:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_HIGHDMA is like any other TX offloads, so allow user to toggle =
it.
This is needed later for bridge and bonding convertsion to hw_features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb8178a..405ce21 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,7 +1080,7 @@ struct net_device {
=20
 	/* Features valid for ethtool to change */
 	/* =3D all defined minus driver/device-class-related */
-#define NETIF_F_NEVER_CHANGE	(NETIF_F_HIGHDMA | NETIF_F_VLAN_CHALLENGE=
D | \
+#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
 				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
 #define NETIF_F_ETHTOOL_BITS	(0x7f3fffff & ~NETIF_F_NEVER_CHANGE)
=20
@@ -1098,6 +1098,7 @@ struct net_device {
=20
 #define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
 				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
+				 NETIF_F_HIGHDMA | \
 				 NETIF_F_SCTP_CSUM | NETIF_F_FCOE_CRC)
=20
 	/*
--=20
1.7.2.5

