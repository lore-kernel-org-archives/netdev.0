From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: 3c509: constify pnp_device_id
Date: Wed, 16 Aug 2017 10:25:59 +0530
Message-ID: <9970265bdf2dd4c4dfbaf6690145d9726748b598.1502859040.git.arvind.yadav.cs@gmail.com>
References: <60c34272432b3411cd5d55728c62481e133f32a6.1502859040.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, jarod@redhat.com, dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60c34272432b3411cd5d55728c62481e133f32a6.1502859040.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pnp_device_id are not supposed to change at runtime. All functions
working with pnp_device_id provided by <linux/pnp.h> work with
const pnp_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/3com/3c509.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index f66c971..077d01d 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -392,7 +392,7 @@ static struct isa_driver el3_isa_driver = {
 static int isa_registered;
 
 #ifdef CONFIG_PNP
-static struct pnp_device_id el3_pnp_ids[] = {
+static const struct pnp_device_id el3_pnp_ids[] = {
 	{ .id = "TCM5090" }, /* 3Com Etherlink III (TP) */
 	{ .id = "TCM5091" }, /* 3Com Etherlink III */
 	{ .id = "TCM5094" }, /* 3Com Etherlink III (combo) */
-- 
2.7.4
