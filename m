From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: veth: set features for MPLS
Date: Wed, 10 Aug 2016 23:43:32 -0700
Message-ID: <1470897812-8213-4-git-send-email-roopa@cumulusnetworks.com>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com,
	simon.horman@netronome.com, tom@herbertland.com, tgraf@suug.ch,
	olivier.dugeon@orange.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32993 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbcHKGvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 02:51:39 -0400
Received: by mail-pa0-f48.google.com with SMTP id ti13so23298634pac.0
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 23:51:39 -0700 (PDT)
In-Reply-To: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>

With hw checksum and gso set, netperf through veth for mpls is
on par without mpls.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e6..5db320a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -340,6 +340,7 @@ static void veth_setup(struct net_device *dev)
 
 	dev->hw_features = VETH_FEATURES;
 	dev->hw_enc_features = VETH_FEATURES;
+	dev->mpls_features = NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
 }
 
 /*
-- 
1.9.1
