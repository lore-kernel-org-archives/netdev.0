From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipv6: remove stale MIB definitions
Date: Thu, 18 Feb 2010 20:12:20 +0200
Message-ID: <20100218181220.GA21184@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:64800 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab0BRSMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:12:20 -0500
Received: by fxm20 with SMTP id 20so9315300fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 10:12:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP6 MIB statistics was per-netns for quite a time.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/icmp.c |    5 -----
 1 file changed, 5 deletions(-)

--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -67,11 +67,6 @@
 #include <asm/uaccess.h>
 #include <asm/system.h>
 
-DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics) __read_mostly;
-EXPORT_SYMBOL(icmpv6_statistics);
-DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics) __read_mostly;
-EXPORT_SYMBOL(icmpv6msg_statistics);
-
 /*
  *	The ICMP socket(s). This is the most convenient way to flow control
  *	our ICMP output as well as maintain a clean interface throughout
