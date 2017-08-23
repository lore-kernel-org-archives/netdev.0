From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 1/3] net: dsa: loop: constify dsa_switch_ops
Date: Wed, 23 Aug 2017 15:46:57 +0530
Message-ID: <1503483419-21780-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_switch_ops are not supposed to change at runtime. All functions
working with dsa_switch_ops provided by <net/dsa.h> work with
const dsa_switch_ops. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index fdd8f38..2418172 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -294,7 +294,7 @@ static int dsa_loop_port_vlan_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static struct dsa_switch_ops dsa_loop_driver = {
+static const struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
 	.get_strings		= dsa_loop_get_strings,
-- 
1.9.1
