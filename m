From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: ethtool: allow ETHTOOL_GSSET_INFO for users
Date: Sun, 22 Jan 2012 11:20:40 +0100 (CET)
Message-ID: <197ddc79ac33a67c56b42a226af3f30056bceb5c.1327227549.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42219 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab2AVKUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 05:20:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow ETHTOOL_GSSET_INFO ethtool ioctl() for unprivileged users.
ETHTOOL_GSTRINGS is already allowed, but is unusable without this one.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

[against net, but probably suitable for stable, too]

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 921aa2b..369b418 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1311,6 +1311,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_GSG:
+	case ETHTOOL_GSSET_INFO:
 	case ETHTOOL_GSTRINGS:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
--=20
1.7.8.3
