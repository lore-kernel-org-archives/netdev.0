From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] eql: fix non-constant printk warning
Date: Fri, 20 Mar 2009 10:14:14 -0700
Message-ID: <20090320101414.32374962@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbZCTROW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 13:14:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/eql.c	2009-02-26 12:04:34.000000000 -0800
+++ b/drivers/net/eql.c	2009-02-26 12:04:52.000000000 -0800
@@ -159,7 +159,7 @@ static void eql_timer(unsigned long para
 	add_timer(&eql->timer);
 }
 
-static char version[] __initdata =
+static const char version[] __initconst =
 	"Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)\n";
 
 static const struct net_device_ops eql_netdev_ops = {
