From: Thomas Graf <tgraf@suug.ch>
Subject: [GENETLINK]: Correctly report errors while registering a multicast group
Date: Tue, 24 Jul 2007 11:44:27 +0200
Message-ID: <20070724094427.GC9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59463 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759957AbXGXJoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 05:44:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/netlink/genetlink.c
===================================================================
--- net-2.6.orig/net/netlink/genetlink.c	2007-07-23 21:54:35.000000000 +0200
+++ net-2.6/net/netlink/genetlink.c	2007-07-23 21:54:54.000000000 +0200
@@ -196,7 +196,7 @@ int genl_register_mc_group(struct genl_f
 	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
  out:
 	genl_unlock();
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL(genl_register_mc_group);
 
