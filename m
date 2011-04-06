From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 12/20] loopback: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:17 -0700
Message-ID: <1302050665-10460-13-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
 <1302050665-10460-12-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54010 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1DFAox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:53 -0400
In-Reply-To: <1302050665-10460-12-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/loopback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index ea0dc45..673fbcc 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -165,8 +165,8 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
-	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
-	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
+	dev->legacy_hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
+	dev->legacy_features	= NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_ALL_TSO
 		| NETIF_F_UFO
 		| NETIF_F_NO_CSUM
-- 
1.7.3.1

