From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: dsa: make dsa_switch_ops const
Date: Wed,  9 Aug 2017 10:34:15 +0530
Message-ID: <1502255055-24751-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these structures const as they are only stored in the ops field of
a dsa_switch structure, which is const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/dsa/dsa_loop.c     | 2 +-
 drivers/net/dsa/lan9303-core.c | 2 +-
 drivers/net/dsa/mt7530.c       | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index 76d6660..7819a9f 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -257,7 +257,7 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static struct dsa_switch_ops dsa_loop_driver = {
+static const struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
 	.get_strings		= dsa_loop_get_strings,
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 15befd1..f058f98 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -797,7 +797,7 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	}
 }
 
-static struct dsa_switch_ops lan9303_switch_ops = {
+static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
 	.get_strings = lan9303_get_strings,
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1270071..7d8cf927 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -979,7 +979,7 @@ static void mt7530_adjust_link(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static struct dsa_switch_ops mt7530_switch_ops = {
+static const struct dsa_switch_ops mt7530_switch_ops = {
 	.get_tag_protocol	= mtk_get_tag_protocol,
 	.setup			= mt7530_setup,
 	.get_strings		= mt7530_get_strings,
-- 
1.9.1
