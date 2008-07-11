From: Christoph Lameter <cl@linux-foundation.org>
Subject: Fix typo in meth driver
Date: Fri, 11 Jul 2008 16:12:34 -0500
Message-ID: <4877CCC2.5050702@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54743 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751698AbYGKVMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 17:12:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An | in an if statement to check a bit? I think this needs to be a &.
As a result of this typo meth will always operate in promiscuous mode.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Index: linux-2.6/drivers/net/meth.c
===================================================================
--- linux-2.6.orig/drivers/net/meth.c	2008-07-11 16:05:00.000000000 -0500
+++ linux-2.6/drivers/net/meth.c	2008-07-11 16:05:02.000000000 -0500
@@ -287,7 +287,7 @@
 
 	/* Initial mode: 10 | Half-duplex | Accept normal packets */
 	priv->mac_ctrl = METH_ACCEPT_MCAST | METH_DEFAULT_IPG;
-	if (dev->flags | IFF_PROMISC)
+	if (dev->flags & IFF_PROMISC)
 		priv->mac_ctrl |= METH_PROMISC;
 	mace->eth.mac_ctrl = priv->mac_ctrl;
 
