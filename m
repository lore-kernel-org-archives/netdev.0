From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 3/3] net: dsa: mt7530: constify dsa_switch_ops
Date: Wed, 23 Aug 2017 15:46:59 +0530
Message-ID: <1503483419-21780-4-git-send-email-arvind.yadav.cs@gmail.com>
References: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34257 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753916AbdHWKRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 06:17:24 -0400
In-Reply-To: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_switch_ops are not supposed to change at runtime. All functions
working with dsa_switch_ops provided by <net/dsa.h> work with
const dsa_switch_ops. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/dsa/mt7530.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 264b281..77ae576 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -1039,7 +1039,7 @@ static void mt7530_adjust_link(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static struct dsa_switch_ops mt7530_switch_ops = {
+static const struct dsa_switch_ops mt7530_switch_ops = {
 	.get_tag_protocol	= mtk_get_tag_protocol,
 	.setup			= mt7530_setup,
 	.get_strings		= mt7530_get_strings,
-- 
1.9.1
