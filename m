From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 3/7] ieee802154: add a helper to put the wpan_phy device
Date: Wed, 16 Sep 2009 02:13:01 +0400
Message-ID: <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:42420 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbZIOWN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:13:57 -0400
Received: by mail-ew0-f206.google.com with SMTP id 2so922680ewy.17
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:14:00 -0700 (PDT)
In-Reply-To: <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/net/wpan-phy.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 547b1e2..5e803a0 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -56,6 +56,12 @@ static inline void *wpan_phy_priv(struct wpan_phy *phy)
 }
 
 struct wpan_phy *wpan_phy_find(const char *str);
+
+static inline void wpan_phy_put(struct wpan_phy *phy)
+{
+	put_device(&phy->dev);
+}
+
 static inline const char *wpan_phy_name(struct wpan_phy *phy)
 {
 	return dev_name(&phy->dev);
-- 
1.6.3.3

