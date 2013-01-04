From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 1/3] l2tp: set netnsok flag for netlink messages
Date: Fri,  4 Jan 2013 17:51:46 +0000
Message-ID: <1357321908-30619-2-git-send-email-tparkin@katalix.com>
References: <1357321908-30619-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53773 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168Ab3ADRwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 12:52:06 -0500
In-Reply-To: <1357321908-30619-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The L2TP netlink code can run in namespaces.  Set the netnsok flag in
genl_family to true to reflect that fact.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
---
 net/l2tp/l2tp_netlink.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index bbba3a1..c1bab22 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -37,6 +37,7 @@ static struct genl_family l2tp_nl_family = {
 	.version	= L2TP_GENL_VERSION,
 	.hdrsize	= 0,
 	.maxattr	= L2TP_ATTR_MAX,
+	.netnsok	= true,
 };
 
 /* Accessed under genl lock */
-- 
1.7.9.5
