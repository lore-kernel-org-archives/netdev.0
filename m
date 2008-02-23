From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [NET] [PS3] gelic wireless driver needs WIRELESS_EXT
	support
Date: Sat, 23 Feb 2008 21:25:53 +0100
Message-ID: <20080223202553.GD7135@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54053 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757593AbYBWU0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:26:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|   CC      drivers/net/ps3_gelic_wireless.o
| /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c: In function 'gelic_wl_setup_netdev_ops':
| /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2660: error: 'struct net_device' has no member named 'wireless_data'
| /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2661: error: 'struct net_device' has no member named 'wireless_handlers'
| make[3]: *** [drivers/net/ps3_gelic_wireless.o] Error 1
| make[2]: *** [drivers/net] Error 2
| make[1]: *** [drivers] Error 2
| make[1]: *** Waiting for unfinished jobs....
| make: *** [sub-make] Error 2

Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..e0a06e9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2363,6 +2363,7 @@ config GELIC_NET
 config GELIC_WIRELESS
        bool "PS3 Wireless support"
        depends on GELIC_NET
+       select WIRELESS_EXT
        help
         This option adds the support for the wireless feature of PS3.
         If you have the wireless-less model of PS3 or have no plan to
-- 
1.5.3.8

