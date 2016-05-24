From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] Documentation: networking: dsa: Remove poll_link description
Date: Mon, 23 May 2016 21:32:15 -0700
Message-ID: <1464064337-8743-2-git-send-email-f.fainelli@gmail.com>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33527 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcEXEca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 00:32:30 -0400
Received: by mail-oi0-f68.google.com with SMTP id m198so1314217oig.0
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 21:32:30 -0700 (PDT)
In-Reply-To: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function has been removed in 4baee937b8d5 ("net: dsa: remove DSA
link polling") in favor of using the PHYLIB polling mechanism.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/dsa/dsa.txt | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 631b0f7ae16f..8303eb8ced79 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -416,11 +416,6 @@ PHY devices and link management
   to the switch port MDIO registers. If unavailable return a negative error
   code.
 
-- poll_link: Function invoked by DSA to query the link state of the switch
-  builtin Ethernet PHYs, per port. This function is responsible for calling
-  netif_carrier_{on,off} when appropriate, and can be used to poll all ports in a
-  single call. Executes from workqueue context.
-
 - adjust_link: Function invoked by the PHY library when a slave network device
   is attached to a PHY device. This function is responsible for appropriately
   configuring the switch port link parameters: speed, duplex, pause based on
-- 
2.7.4
