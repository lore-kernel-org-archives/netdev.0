From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/03: fix selection of "LED" target in netfilter
Date: Wed,  8 Apr 2009 18:52:18 +0200 (MEST)
Message-ID: <20090408165214.6702.69359.sendpatchset@x2.localnet>
References: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54361 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbZDHQwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 12:52:20 -0400
In-Reply-To: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3ae16f13027c26cb4c227392116c2027524a6444
Author: Alex Riesen <fork0@users.sourceforge.net>
Date:   Mon Apr 6 17:09:43 2009 +0200

    netfilter: fix selection of "LED" target in netfilter
    
    It's plural, not LED_TRIGGERS.
    
    Signed-off-by: Alex Riesen <fork0@users.sourceforge.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index bb279bf..2329c5f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -374,7 +374,7 @@ config NETFILTER_XT_TARGET_HL
 
 config NETFILTER_XT_TARGET_LED
 	tristate '"LED" target support'
-	depends on LEDS_CLASS && LED_TRIGGERS
+	depends on LEDS_CLASS && LEDS_TRIGGERS
 	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `LED' target, which allows you to blink LEDs in
