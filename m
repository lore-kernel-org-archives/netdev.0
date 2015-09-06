From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: bridge: remove unnecessary switchdev include
Date: Sat,  5 Sep 2015 21:49:41 -0400
Message-ID: <1441504181-20376-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the unnecessary switchdev.h include from br_netlink.c.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_netlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index af5e187..ea748c9 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -16,7 +16,6 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
-#include <net/switchdev.h>
 #include <uapi/linux/if_bridge.h>
 
 #include "br_private.h"
-- 
2.5.1
