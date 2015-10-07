From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/6] net: dsa: include dsa.h in dsa_priv.h
Date: Wed,  7 Oct 2015 19:48:27 -0400
Message-ID: <1444261711-1829-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_priv.h uses dsa specific structures, as well as the files using it,
so include dsa.h here.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 311796c8..4522f47 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -14,6 +14,7 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 #include <linux/netpoll.h>
+#include <net/dsa.h>
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
-- 
2.6.0
