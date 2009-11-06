From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 01/17] wpan-phy: add a helper to put the wpan_phy device
Date: Fri,  6 Nov 2009 15:39:25 +0300
Message-ID: <1257511181-19403-2-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:64857 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069AbZKFMkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:37 -0500
Received: by ey-out-2122.google.com with SMTP id 9so85501eyd.5
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:42 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
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
1.6.5

