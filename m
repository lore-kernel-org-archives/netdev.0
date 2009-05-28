From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: fix build with NET_POLL_CONTROLLER
Date: Thu, 28 May 2009 22:05:53 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0905282200460.12066@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0905260116120.18180@loopy.telegraphics.com.au>
 <10f740e80905270149q2b906d53u8bf71b7d382a57a3@mail.gmail.com>
 <Pine.LNX.4.64.0905281454450.9036@loopy.telegraphics.com.au>
 <20090527.223355.118242797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	geert.uytterhoeven@gmail.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loopy.telegraphics.com.au ([202.45.126.152]:46874 "EHLO
	loopy.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbZE1MGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 08:06:12 -0400
In-Reply-To: <20090527.223355.118242797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the build for CONFIG_NET_POLL_CONTROLLER that I broke with
217cbfa856dc1cbc2890781626c4032d9e3ec59f.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

--- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
+++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
@@ -489,7 +489,7 @@
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= ei_poll,
+	.ndo_poll_controller	= __ei_poll,
 #endif
 };
 
