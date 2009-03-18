From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] rtnetlink: add new value for DHCP added routes
Date: Wed, 18 Mar 2009 12:27:14 -0700
Message-ID: <20090318122714.5d36d62f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37142 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbZCRT1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 15:27:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To improve manageability, it would be good to be able to disambiguate routes
added by administrator from those added by DHCP client.  The only necessary
kernel change is to add value to rtnetlink include file so iproute2 utility
can use it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/rtnetlink.h	2009-03-18 12:23:01.978726869 -0700
+++ b/include/linux/rtnetlink.h	2009-03-18 12:23:37.546430187 -0700
@@ -217,6 +217,7 @@ enum
 #define RTPROT_DNROUTED	13	/* DECnet routing daemon */
 #define RTPROT_XORP	14	/* XORP */
 #define RTPROT_NTK	15	/* Netsukuku */
+#define RTPROT_DHCP	16      /* DHCP client */
 
 /* rtm_scope
 
