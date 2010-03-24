From: Dan Carpenter <error27@gmail.com>
Subject: [patch] llc: cleanup: remove dead code from llc_init()
Date: Wed, 24 Mar 2010 14:55:10 +0300
Message-ID: <20100324115510.GC21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:50893 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab0CXLzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 07:55:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need "dev" any more after:
	a5a04819c5740cb1aa217af2cc8f5ef26f33d744
	[LLC]: station source mac address

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 78167e8..2bb0ddf 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -144,12 +144,6 @@ static struct packet_type llc_tr_packet_type __read_mostly = {
 
 static int __init llc_init(void)
 {
-	struct net_device *dev;
-
-	dev = first_net_device(&init_net);
-	if (dev != NULL)
-		dev = next_net_device(dev);
-
 	dev_add_pack(&llc_packet_type);
 	dev_add_pack(&llc_tr_packet_type);
 	return 0;
