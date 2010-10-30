From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/4] Ethtool: Introduce hw_features field in struct netdevice
Date: Sat, 30 Oct 2010 06:27:05 +0200
Message-ID: <a66de7df50260c5ed2a299a9594cac5bcb0ddadd.1288496404.git.mirq-linux@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49492 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782Ab0JaEAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 00:00:33 -0400
In-Reply-To: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..f11a5a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -884,6 +884,8 @@ struct net_device {
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
 				 NETIF_F_FRAGLIST)
+	/* ethtool-toggable features */
+	unsigned long		hw_features;
=20
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
--=20
1.7.1

