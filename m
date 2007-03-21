From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] [NETLINK]: Remove unused groups variable
Date: Wed, 21 Mar 2007 01:18:13 +0100
Message-ID: <20070321001900.603893237@lsx.localdomain>
References: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44309 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179AbXCUAUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:20:03 -0400
Content-Disposition: inline; filename=netlink_create_unused_variable
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Leftover from dynamic multicast groups allocation work.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/netlink/af_netlink.c
===================================================================
--- net-2.6.orig/net/netlink/af_netlink.c	2007-01-23 14:09:34.000000000 +0100
+++ net-2.6/net/netlink/af_netlink.c	2007-01-23 14:09:49.000000000 +0100
@@ -396,7 +396,6 @@ static int netlink_create(struct socket 
 {
 	struct module *module = NULL;
 	struct netlink_sock *nlk;
-	unsigned int groups;
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -418,7 +417,6 @@ static int netlink_create(struct socket 
 	if (nl_table[protocol].registered &&
 	    try_module_get(nl_table[protocol].module))
 		module = nl_table[protocol].module;
-	groups = nl_table[protocol].groups;
 	netlink_unlock_table();
 
 	if ((err = __netlink_create(sock, protocol)) < 0)

--

