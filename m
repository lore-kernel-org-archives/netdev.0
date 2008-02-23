From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 20:35:17 +0100
Message-ID: <20080223193517.GA6704@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:57997 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196AbYBWTfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 14:35:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so select it.
Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..a116056 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2363,6 +2363,7 @@ config GELIC_NET
 config GELIC_WIRELESS
        bool "PS3 Wireless support"
        depends on GELIC_NET
+       select MAC80211
        help
         This option adds the support for the wireless feature of PS3.
         If you have the wireless-less model of PS3 or have no plan to
-- 
1.5.3.8

