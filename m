From: Joe Perches <joe@perches.com>
Subject: [PATCH] phy/ethtool: Add missing SPEED_<foo> strings
Date: Sun,  2 Apr 2017 14:30:06 -0700
Message-ID: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add all the currently available SPEED_<foo> strings.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/phy/phy.c        | 14 ++++++++++++++
 include/uapi/linux/ethtool.h |  1 +
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d019bbf42c31..e7d0367a1455 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -50,8 +50,22 @@ static const char *phy_speed_to_str(int speed)
 		return "1Gbps";
 	case SPEED_2500:
 		return "2.5Gbps";
+	case SPEED_5000:
+		return "5Gbps";
 	case SPEED_10000:
 		return "10Gbps";
+	case SPEED_20000:
+		return "20Gbps";
+	case SPEED_25000:
+		return "25Gbps";
+	case SPEED_40000:
+		return "40Gbps";
+	case SPEED_50000:
+		return "50Gbps";
+	case SPEED_56000:
+		return "56Gbps";
+	case SPEED_100000:
+		return "100Gbps";
 	case SPEED_UNKNOWN:
 		return "Unknown";
 	default:
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 3dc91a46e8b8..5f4ea28eabe4 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1487,6 +1487,7 @@ enum ethtool_link_mode_bit_indices {
  */
 
 /* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
+/* Update drivers/net/phy/phy.c:phy_speed_to_str() when adding new values */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
-- 
2.10.0.rc2.1.g053435c
