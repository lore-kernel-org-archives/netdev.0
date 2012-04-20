From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 04/10] pppox: Replace __attribute__((packed)) in if_pppox.h
Date: Fri, 20 Apr 2012 10:02:47 +0100
Message-ID: <1334912573-28804-5-git-send-email-jchapman@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:56662 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038Ab2DTJDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 05:03:00 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch warns about the use of __attribute__((packed)). So use the
recommended __packed syntax instead.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 include/linux/if_pppox.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 6720d57..09c474c 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -70,7 +70,7 @@ struct sockaddr_pppox {
 		struct pppoe_addr  pppoe;
 		struct pptp_addr   pptp;
 	} sa_addr;
-} __attribute__((packed));
+} __packed;
 
 /* The use of the above union isn't viable because the size of this
  * struct must stay fixed over time -- applications use sizeof(struct
@@ -81,13 +81,13 @@ struct sockaddr_pppol2tp {
 	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tp_addr pppol2tp;
-} __attribute__((packed));
+} __packed;
 
 struct sockaddr_pppol2tpin6 {
 	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpin6_addr pppol2tp;
-} __attribute__((packed));
+} __packed;
 
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
@@ -96,13 +96,13 @@ struct sockaddr_pppol2tpv3 {
 	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpv3_addr pppol2tp;
-} __attribute__((packed));
+} __packed;
 
 struct sockaddr_pppol2tpv3in6 {
 	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpv3in6_addr pppol2tp;
-} __attribute__((packed));
+} __packed;
 
 /*********************************************************************
  *
@@ -152,7 +152,7 @@ struct pppoe_hdr {
 	__be16 sid;
 	__be16 length;
 	struct pppoe_tag tag[0];
-} __attribute__((packed));
+} __packed;
 
 /* Length of entire PPPoE + PPP header */
 #define PPPOE_SES_HLEN	8
-- 
1.7.0.4
