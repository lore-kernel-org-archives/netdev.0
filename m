From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Don't use RX clock as TX clock.
Date: Tue, 29 Apr 2008 13:03:57 +0200
Message-ID: <1209467037-30612-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>,
	Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:16745 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753793AbYD2LD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 07:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9fb1e350e16164d56990dde036ae9c0a2fd3f634,
ucc_geth: use rx-clock-name and tx-clock-name device tree properties
Introduced a typo that made the driver use the RX clock
as TX clock, causing massive TX errors.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

Resending as the first one got rejected du to missing commas.

 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 28431aa..2de153f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3907,7 +3907,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 			return -EINVAL;
 		}
 	} else {
-		prop = of_get_property(np, "rx-clock", NULL);
+		prop = of_get_property(np, "tx-clock", NULL);
 		if (!prop) {
 			printk(KERN_ERR
 				"ucc_geth: mising tx-clock-name property\n");
-- 
1.5.5.1

