From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 1/3] net: if_arp: add ARPHRD_NETLINK type
Date: Wed, 19 Jun 2013 20:04:44 +0200
Message-ID: <1371665086-19677-2-git-send-email-dborkman@redhat.com>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934980Ab3FSSFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:05:16 -0400
In-Reply-To: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
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
