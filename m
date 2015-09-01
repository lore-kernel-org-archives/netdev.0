From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 04/21] net: rbridge: add CONFIG_TRILL
Date: Tue,  1 Sep 2015 17:42:59 +0200
Message-ID: <1441122196-11662-5-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:34282 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752886AbbIAPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:42 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
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
2.1.4
