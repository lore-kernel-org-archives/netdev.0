From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] ipx: use constant for strings and desciptor
Date: Fri, 20 Mar 2009 08:45:39 -0700
Message-ID: <20090320084539.04120796@nehalam>
References: <20090320084314.5761b1d9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39368 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453AbZCTPpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 11:45:47 -0400
In-Reply-To: <20090320084314.5761b1d9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compiler warning about non-const format string.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipx/af_ipx.c	2009-03-19 23:37:56.671964109 -0700
+++ b/net/ipx/af_ipx.c	2009-03-19 23:46:55.613777665 -0700
@@ -1975,15 +1975,15 @@ static struct notifier_block ipx_dev_not
 extern struct datalink_proto *make_EII_client(void);
 extern void destroy_EII_client(struct datalink_proto *);
 
-static unsigned char ipx_8022_type = 0xE0;
-static unsigned char ipx_snap_id[5] = { 0x0, 0x0, 0x0, 0x81, 0x37 };
-static char ipx_EII_err_msg[] __initdata =
+static const unsigned char ipx_8022_type = 0xE0;
+static const unsigned char ipx_snap_id[5] = { 0x0, 0x0, 0x0, 0x81, 0x37 };
+static const char ipx_EII_err_msg[] __initconst =
 	KERN_CRIT "IPX: Unable to register with Ethernet II\n";
-static char ipx_8023_err_msg[] __initdata =
+static const char ipx_8023_err_msg[] __initconst =
 	KERN_CRIT "IPX: Unable to register with 802.3\n";
-static char ipx_llc_err_msg[] __initdata =
+static const char ipx_llc_err_msg[] __initconst =
 	KERN_CRIT "IPX: Unable to register with 802.2\n";
-static char ipx_snap_err_msg[] __initdata =
+static const char ipx_snap_err_msg[] __initconst =
 	KERN_CRIT "IPX: Unable to register with SNAP\n";
 
 static int __init ipx_init(void)
