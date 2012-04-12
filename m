From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: phonet_net_id can be static (sparse)
Date: Thu, 12 Apr 2012 16:39:16 +0300
Message-ID: <1334237958-22855-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:50538 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934185Ab2DLNqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 09:46:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 9b9a85e..631cd51 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -44,7 +44,7 @@ struct phonet_net {
 	struct phonet_routes routes;
 };
=20
-int phonet_net_id __read_mostly;
+static int phonet_net_id __read_mostly;
=20
 static struct phonet_net *phonet_pernet(struct net *net)
 {
--=20
1.7.5.4
