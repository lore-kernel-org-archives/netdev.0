From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 09/20] net-phonet: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:14 -0700
Message-ID: <1302050665-10460-10-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28062 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab1DFAoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:55 -0400
In-Reply-To: <1302050665-10460-9-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/phonet/pep-gprs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index d012089..d0fcbe5 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -236,7 +236,7 @@ static const struct net_device_ops gprs_netdev_ops = {
 
 static void gprs_setup(struct net_device *dev)
 {
-	dev->features		= NETIF_F_FRAGLIST;
+	dev->legacy_features	= NETIF_F_FRAGLIST;
 	dev->type		= ARPHRD_PHONET_PIPE;
 	dev->flags		= IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		= GPRS_DEFAULT_MTU;
-- 
1.7.3.1

