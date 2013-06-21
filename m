From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: if_arp: add ARPHRD_NETLINK type
Date: Fri, 21 Jun 2013 19:38:06 +0200
Message-ID: <1371836288-13122-2-git-send-email-dborkman@redhat.com>
References: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423452Ab3FURiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 13:38:11 -0400
In-Reply-To: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patch adds the definition of ARPHRD_NETLINK which can for
example be used by netlink monitoring devices as device type. So that
sockaddr_ll can pick it up and based on that choose the correct packet
dissector.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/if_arp.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 82c7d1b..d7fea34 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -93,6 +93,7 @@
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
 #define ARPHRD_CAIF	822		/* CAIF media type		*/
 #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
+#define ARPHRD_NETLINK	824		/* Netlink header		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
-- 
1.7.11.7
