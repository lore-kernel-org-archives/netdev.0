From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 01/12] net-caif: add CAIF protocol definitions
Date: Wed, 31 Mar 2010 01:56:19 +0200
Message-ID: <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692Ab0C3X4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:56:44 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400C9LD6HAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:41 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:41 +0200 (CEST)
In-reply-to: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
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

