From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 2/3] net: dsa: lan9303: constify dsa_switch_ops
Date: Wed, 23 Aug 2017 15:46:58 +0530
Message-ID: <1503483419-21780-3-git-send-email-arvind.yadav.cs@gmail.com>
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
 drivers/net/dsa/lan9303-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index cd76e61..d4820d2 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -780,7 +780,7 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	}
 }
 
-static struct dsa_switch_ops lan9303_switch_ops = {
+static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
 	.get_strings = lan9303_get_strings,
-- 
1.9.1
