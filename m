From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 02/18] d80211:  master link
Date: Mon, 21 Aug 2006 09:41:09 +0200
Message-ID: <20060821075159.017613319@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48576 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030316AbWHUIB7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:01:59 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-masterlink.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a link from the wiphy to the master device in sysfs.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:15.968192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:16.818192788 +0200
@@ -4449,6 +4449,7 @@ int ieee80211_register_hw(struct net_dev
 		rtnl_unlock();
 		goto fail_dev;
 	}
+	sysfs_create_link(&local->class_dev.kobj, &dev->class_dev.kobj, "master");
 	result = ieee80211_sysfs_add_netdevice(dev);
 	rtnl_unlock();
 	if (result < 0)

--
