From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 12/12] [IEEE802154] ieee802154: set default device as wpan
Date: Wed, 30 Nov 2011 17:28:04 +0300
Message-ID: <1322663284-4166-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58847 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1K3N2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:28:21 -0500
Received: by eaak14 with SMTP id k14so666792eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 05:28:20 -0800 (PST)
In-Reply-To: <20111130141827.GA3739@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set default device type to wpan during creating interface.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/nl-phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 0c02fcf..ab211d2 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -179,7 +179,7 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 	const char *devname;
 	int rc = -ENOBUFS;
 	struct net_device *dev;
-        int type = -EINVAL;
+        int type = IEEE802154_DEV_WPAN;
 
 	pr_debug("%s\n", __func__);
 
-- 
1.7.2.3
