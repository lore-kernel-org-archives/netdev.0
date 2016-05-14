From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: switchdev: Drop EXPERIMENTAL from description
Date: Sat, 14 May 2016 12:49:54 -0700
Message-ID: <1463255394-15299-1-git-send-email-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switchdev has been around for quite a while now, putting "EXPERIMENTAL"
in the description is no longer accurate, drop it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/switchdev/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
index 86a47e1..651fa20 100644
--- a/net/switchdev/Kconfig
+++ b/net/switchdev/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config NET_SWITCHDEV
-	bool "Switch (and switch-ish) device support (EXPERIMENTAL)"
+	bool "Switch (and switch-ish) device support"
 	depends on INET
 	---help---
 	  This module provides glue between core networking code and device
-- 
2.7.4
