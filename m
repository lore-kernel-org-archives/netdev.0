From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 3/6] 6lowpan: move 6lowpan.c to 6lowpan_rtnl.c
Date: Fri, 21 Feb 2014 16:15:08 +0100
Message-ID: <1392995711-19563-4-git-send-email-alex.aring@gmail.com>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:42701 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbaBUPQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 10:16:27 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so801875eek.27
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 07:16:25 -0800 (PST)
In-Reply-To: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
should move 6lowpan.c to 6lowpan.ko. Then we can support multiple source
files for 6lowpan module.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Tested-by: Martin Townsend <martin.townsend@xsilon.com>
---
 net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} | 0
 net/ieee802154/Makefile                      | 1 +
 2 files changed, 1 insertion(+)
 rename net/ieee802154/{6lowpan.c => 6lowpan_rtnl.c} (100%)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan_rtnl.c
similarity index 100%
rename from net/ieee802154/6lowpan.c
rename to net/ieee802154/6lowpan_rtnl.c
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index e8f0588..3d08adf 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -2,5 +2,6 @@ obj-$(CONFIG_IEEE802154) += ieee802154.o af_802154.o
 obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
 obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
 
+6lowpan-y := 6lowpan_rtnl.o
 ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
-- 
1.9.0
