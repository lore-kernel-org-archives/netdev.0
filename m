From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: mib6 section fixlet
Date: Mon, 13 Oct 2008 12:27:55 +0400
Message-ID: <20081013082755.GB19572@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:57807 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358AbYJMIZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 04:25:03 -0400
Received: by ey-out-2122.google.com with SMTP id 6so536863eyi.37
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 01:25:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  LD      net/ipv6/ipv6.o
WARNING: net/ipv6/ipv6.o(.text+0xd8): Section mismatch in reference from the function inet6_net_init() to the function .init.text:ipv6_init_mibs()

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/af_inet6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -834,7 +834,7 @@ static void __net_exit ipv6_cleanup_mibs(struct net *net)
 	snmp_mib_free((void **)net->mib.icmpv6msg_statistics);
 }
 
-static int inet6_net_init(struct net *net)
+static int __net_init inet6_net_init(struct net *net)
 {
 	int err = 0;
 
