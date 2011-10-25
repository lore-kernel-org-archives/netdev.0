From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 8/9] net: extend netdev_features_t to 64 bits
Date: Tue, 25 Oct 2011 02:36:33 +0200 (CEST)
Message-ID: <cb4d6010589b4d99097a82e2e8cea5f51ef6f765.1319495302.git.mirq-linux@rere.qmqm.pl>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45094 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab1JYAgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 20:36:38 -0400
In-Reply-To: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdev_features.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 04ac8f8..20e3a1f 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -12,7 +12,7 @@
=20
 #include <linux/types.h>
=20
-typedef u32 netdev_features_t;
+typedef u64 netdev_features_t;
=20
 enum {
 	NETIF_F_SG_BIT,			/* Scatter/gather IO. */
--=20
1.7.6.3
