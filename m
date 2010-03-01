From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v6 01/12] net-caif: add CAIF protocol definitions
Date: Mon,  1 Mar 2010 13:12:28 +0100
Message-ID: <1267445559-1911-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gktv.no ([80.239.85.213]:33754 "EHLO mail.gktv.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab0CAMNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 07:13:07 -0500
In-Reply-To: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add CAIF definitions to existing header files.
Files: if_arp.h, if_ether.h, socket.h.
Types: ARPHRD_CAIF, ETH_P_CAIF, AF_CAIF, PF_CAIF, SOL_CAIF, N_CAIF

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/if_arp.h   |    1 +
 include/linux/if_ether.h |    1 +
 include/linux/socket.h   |    5 ++++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index e80b7f8..6d722f4 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -90,6 +90,7 @@
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
+#define ARPHRD_CAIF	822		/* CAIF media type		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 299b412..bed7a46 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -109,6 +109,7 @@
 #define ETH_P_TRAILER	0x001C		/* Trailer switch tagging	*/
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
+#define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 7b3aae2..960659b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -189,7 +189,8 @@ struct ucred {
 #define AF_ISDN		34	/* mISDN sockets 		*/
 #define AF_PHONET	35	/* Phonet sockets		*/
 #define AF_IEEE802154	36	/* IEEE802154 sockets		*/
-#define AF_MAX		37	/* For now.. */
+#define AF_CAIF		37	/* CAIF sockets			*/
+#define AF_MAX		38	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -229,6 +230,7 @@ struct ucred {
 #define PF_ISDN		AF_ISDN
 #define PF_PHONET	AF_PHONET
 #define PF_IEEE802154	AF_IEEE802154
+#define PF_CAIF		AF_CAIF
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
@@ -300,6 +302,7 @@ struct ucred {
 #define SOL_PNPIPE	275
 #define SOL_RDS		276
 #define SOL_IUCV	277
+#define SOL_CAIF	278
 
 /* IPX options */
 #define IPX_TYPE	1
-- 
1.6.3.3

