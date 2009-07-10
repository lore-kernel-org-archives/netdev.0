From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: remove unused exports
Date: Fri, 10 Jul 2009 20:32:06 +0200
Message-ID: <1247250726.29747.15.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49974 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725AbZGJScL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 14:32:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I added those myself in commits b4ff4f04 and 84659eb5,
but I see no reason now why they should be exported,
only generic netlink uses them which cannot be modular.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/netlink/af_netlink.c |    2 --
 1 file changed, 2 deletions(-)

--- wireless-testing.orig/net/netlink/af_netlink.c	2009-07-10 20:21:46.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-07-10 20:26:28.000000000 +0200
@@ -1575,7 +1575,6 @@ int netlink_change_ngroups(struct sock *
 	kfree(old);
 	return err;
 }
-EXPORT_SYMBOL(netlink_change_ngroups);
 
 /**
  * netlink_clear_multicast_users - kick off multicast listeners
@@ -1598,7 +1597,6 @@ void netlink_clear_multicast_users(struc
 
 	netlink_table_ungrab();
 }
-EXPORT_SYMBOL(netlink_clear_multicast_users);
 
 void netlink_set_nonroot(int protocol, unsigned int flags)
 {


