From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v3 4/5] net: dsa: make usage of mv88e6xxx common remove
 function
Date: Thu, 29 Oct 2015 15:45:42 +0100
Message-ID: <56323116.3060509@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make usage of previously introduced mv88e6xxx common remove
function in all mv88e6xxx drivers.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6123_61_65.c | 1 +
 drivers/net/dsa/mv88e6131.c       | 1 +
 drivers/net/dsa/mv88e6171.c       | 1 +
 drivers/net/dsa/mv88e6352.c       | 1 +
 4 files changed, 4 insertions(+)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 4bcfd68..1773c99 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -122,6 +122,7 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_61_65_probe,
 	.setup			= mv88e6123_61_65_setup,
+	.remove			= mv88e6xxx_remove_common,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read,
 	.phy_write		= mv88e6xxx_phy_write,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index c73121c..677a6cb 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -175,6 +175,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
 	.setup			= mv88e6131_setup,
+	.remove			= mv88e6xxx_remove_common,
 	.set_addr		= mv88e6xxx_set_addr_direct,
 	.phy_read		= mv88e6131_phy_read,
 	.phy_write		= mv88e6131_phy_write,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 2c8eb6f..382529b 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -101,6 +101,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6171_probe,
 	.setup			= mv88e6171_setup,
+	.remove			= mv88e6xxx_remove_common,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cbf4dd8..7938901 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -321,6 +321,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6352_probe,
 	.setup			= mv88e6352_setup,
+	.remove			= mv88e6xxx_remove_common,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
 	.phy_read		= mv88e6xxx_phy_read_indirect,
 	.phy_write		= mv88e6xxx_phy_write_indirect,
-- 
1.9.1
