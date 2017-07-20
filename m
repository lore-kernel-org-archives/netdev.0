From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: b53: Add missing ARL entries for BCM53125
Date: Thu, 20 Jul 2017 12:25:22 -0700
Message-ID: <20170720192522.18048-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The BCM53125 entry was missing an arl_entries member which would
basically prevent the ARL search from terminating properly. This switch
has 4 ARL entries, so add that.

Fixes: 1da6df85c6fb ("net: dsa: b53: Implement ARL add/del/dump operations")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index e68d368e20ac..7f36d3e3c98b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1665,6 +1665,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.dev_name = "BCM53125",
 		.vlans = 4096,
 		.enabled_ports = 0xff,
+		.arl_entries = 4,
 		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
-- 
2.9.3
