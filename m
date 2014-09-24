From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 04/24] net: rbridge: Add CONFIG_TRILL
Date: Wed, 24 Sep 2014 17:52:00 +0200
Message-ID: <1411573940-14079-5-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:36868 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbaIXP6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:13 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add TRILL option kconfig file in order to enable RBridge feature
in linux Bridge

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/Kconfig | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index aa0d3b2..2381567 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -60,3 +60,11 @@ config BRIDGE_VLAN_FILTERING
 	  Say N to exclude this support and reduce the binary size.
 
 	  If unsure, say Y.
+
+config TRILL
+	bool "Enable RBridge capabilities (RFC6325) (EXPERIMENTAL)"
+	depends on BRIDGE
+	default n
+	---help---
+	  enable trill option on bridge to get Rbridge
+	  If unsure, say N.
-- 
1.9.1
