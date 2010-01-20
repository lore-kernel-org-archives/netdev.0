From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 01/13] net-caif: add CAIF protocol definitions
Date: Wed, 20 Jan 2010 23:55:18 +0100
Message-ID: <1264028130-14364-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055Ab0ATX4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:20 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CD8IDDGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:01 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:01 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
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

