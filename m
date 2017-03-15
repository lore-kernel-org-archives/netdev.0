From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/3] net: dsa: dsa_fastest_ageing_time return unsigned
Date: Wed, 15 Mar 2017 15:53:48 -0400
Message-ID: <20170315195350.11059-2-vivien.didelot@savoirfairelinux.com>
References: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315195350.11059-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ageing time is defined as unsigned int, so make
dsa_fastest_ageing_time return an unsigned int instead of int.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index c34872e1febc..cec47e843570 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -419,8 +419,8 @@ static int dsa_slave_vlan_filtering(struct net_device *dev,
 	return 0;
 }
 
-static int dsa_fastest_ageing_time(struct dsa_switch *ds,
-				   unsigned int ageing_time)
+static unsigned int dsa_fastest_ageing_time(struct dsa_switch *ds,
+					    unsigned int ageing_time)
 {
 	int i;
 
-- 
2.12.0
