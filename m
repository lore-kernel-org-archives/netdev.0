From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] connector: add module alias
Date: Thu, 9 Dec 2010 09:36:46 -0800
Message-ID: <20101209093646.1b5a6abb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34352 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab0LIRgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 12:36:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since connector can be built as a module and uses netlink socket
to communicate. The module should have an alias to autoload when socket
of NETLINK_CONNECTOR type is requested.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/connector/connector.c	2010-12-09 09:19:05.549120343 -0800
+++ b/drivers/connector/connector.c	2010-12-09 09:19:52.795051458 -0800
@@ -36,6 +36,7 @@
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
 MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
+MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_CONNECTOR);
 
 static struct cn_dev cdev;
 
