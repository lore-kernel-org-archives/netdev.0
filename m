From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] rtnetlink: add babel protocol recognition
Date: Thu, 6 Nov 2014 08:10:14 -0800
Message-ID: <20141106081014.38a23889@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@bufferbloat.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63645 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaKFQK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:10:28 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so1512721pab.33
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 08:10:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@bufferbloat.net>

Babel uses rt_proto 42. Add to userspace visible header file.

Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/uapi/linux/rtnetlink.h | 1 +
 1 file changed, 1 insertion(+)

--- a/include/uapi/linux/rtnetlink.h	2014-11-06 08:07:16.041165946 -0800
+++ b/include/uapi/linux/rtnetlink.h	2014-11-06 08:07:16.029165894 -0800
@@ -235,6 +235,7 @@ enum {
 #define RTPROT_NTK	15	/* Netsukuku */
 #define RTPROT_DHCP	16      /* DHCP client */
 #define RTPROT_MROUTED	17      /* Multicast daemon */
+#define RTPROT_BABEL	42      /* Babel daemon */
 
 /* rtm_scope
 
