From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: add RTNL_ASSERT in __netdev_update_features()
Date: Tue, 12 Apr 2011 21:56:38 +0200 (CEST)
Message-ID: <20110412195638.3983613A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37313 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756917Ab1DLT4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 15:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 95897ff..ae9ac15 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5241,6 +5241,8 @@ int __netdev_update_features(struct net_device *d=
ev)
 	u32 features;
 	int err =3D 0;
=20
+	ASSERT_RTNL();
+
 	features =3D netdev_get_wanted_features(dev);
=20
 	if (dev->netdev_ops->ndo_fix_features)
--=20
1.7.2.5

