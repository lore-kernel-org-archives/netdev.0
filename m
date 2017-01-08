From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: select NET_SWITCHDEV
Date: Sun,  8 Jan 2017 18:17:24 -0500
Message-ID: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58284 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937629AbdAHXSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:18:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA wraps SWITCHDEV, thus select it instead of depending on it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 2ae9bb357523..675acbf1502d 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -6,7 +6,8 @@ config HAVE_NET_DSA
 
 config NET_DSA
 	tristate "Distributed Switch Architecture"
-	depends on HAVE_NET_DSA && NET_SWITCHDEV
+	depends on HAVE_NET_DSA
+	select NET_SWITCHDEV
 	select PHYLIB
 	---help---
 	  Say Y if you want to enable support for the hardware switches supported
-- 
2.11.0
