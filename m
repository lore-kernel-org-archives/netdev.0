From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: vlan_features comment clarification
Date: Tue, 12 Apr 2011 16:07:39 +0200 (CEST)
Message-ID: <20110412140739.1DF1713909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55585 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756165Ab1DLOHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 10:07:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09d2624..cb8178a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1035,7 +1035,7 @@ struct net_device {
 	u32			hw_features;
 	/* user-requested features */
 	u32			wanted_features;
-	/* VLAN feature mask */
+	/* mask of features inheritable by VLAN devices */
 	u32			vlan_features;
=20
 	/* Net device feature bits; if you change something,
--=20
1.7.2.5

