From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 09/10] net: remove /sys/class/net/*/features
Date: Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
Message-ID: <ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59822 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same information and more can be obtained by using ethtool
with ETHTOOL_GFEATURES.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/net-sysfs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 33d2a1f..1683e5d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -100,7 +100,6 @@ NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
-NETDEVICE_SHOW(features, fmt_hex);
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
=20
@@ -312,7 +311,6 @@ static struct device_attribute net_class_attributes=
[] =3D {
 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
-	__ATTR(features, S_IRUGO, show_features, NULL),
 	__ATTR(type, S_IRUGO, show_type, NULL),
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
 	__ATTR(address, S_IRUGO, show_address, NULL),
--=20
1.7.5.4

