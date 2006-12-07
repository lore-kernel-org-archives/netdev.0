From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Restore API compatibility of address and neighbour bits
Date: Thu, 7 Dec 2006 11:55:02 +0100
Message-ID: <20061207105502.GJ8693@postel.suug.ch>
References: <200612062033.34754.stefan@loplof.de> <20061206.165638.30168567.davem@davemloft.net> <20061207104721.GI8693@postel.suug.ch> <20061207.025140.75779834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan@loplof.de, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52817 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032019AbWLGKyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:54:41 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061207.025140.75779834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Restore API compatibility due to bits moved from rtnetlink.h to
separate headers.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/linux/rtnetlink.h
===================================================================
--- net-2.6.orig/include/linux/rtnetlink.h	2006-12-07 11:25:29.000000000 +0100
+++ net-2.6/include/linux/rtnetlink.h	2006-12-07 11:32:25.000000000 +0100
@@ -3,6 +3,8 @@
 
 #include <linux/netlink.h>
 #include <linux/if_link.h>
+#include <linux/if_addr.h>
+#include <linux/neighbour.h>
 
 /****
  *		Routing/neighbour discovery messages.
