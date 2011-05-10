From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] netdevice.h: Align struct netdevices members
Date: Mon, 09 May 2011 20:42:46 -0700
Message-ID: <1304998966.19586.104.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1433 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717Ab1EJDmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 23:42:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save a bit of space.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d5de66a..0fcb86b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1020,9 +1020,6 @@ struct net_device {
 	 *	part of the usual set specified in Space.c.
 	 */
 
-	unsigned char		if_port;	/* Selectable AUI, TP,..*/
-	unsigned char		dma;		/* DMA channel		*/
-
 	unsigned long		state;
 
 	struct list_head	dev_list;
@@ -1141,13 +1138,16 @@ struct net_device {
 	const struct header_ops *header_ops;
 
 	unsigned int		flags;	/* interface flags (a la BSD)	*/
+	unsigned int		priv_flags; /* Like 'flags' but invisible to userspace. */
 	unsigned short		gflags;
-        unsigned int            priv_flags; /* Like 'flags' but invisible to userspace. */
 	unsigned short		padded;	/* How much padding added by alloc_netdev() */
 
 	unsigned char		operstate; /* RFC2863 operstate */
 	unsigned char		link_mode; /* mapping policy to operstate */
 
+	unsigned char		if_port;	/* Selectable AUI, TP,..*/
+	unsigned char		dma;		/* DMA channel		*/
+
 	unsigned int		mtu;	/* interface MTU value		*/
 	unsigned short		type;	/* interface hardware type	*/
 	unsigned short		hard_header_len;	/* hardware hdr length	*/


