From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH] renesas/sh_eth.c: fix linux/interrupt.h included twice
Date: Wed, 15 Feb 2012 18:54:43 +0100
Message-ID: <1329328483-4682-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:41595 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754277Ab2BORys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 12:54:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove double include of linux/interrupt.h.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/renesas/sh_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 87b6501..59524f1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -34,7 +34,6 @@
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
-#include <linux/interrupt.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/ethtool.h>
-- 
1.7.8.3
