From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 4/4] net: dsa: bcm_sf2: Add support for port mirroring
Date: Mon, 30 Jan 2017 12:41:43 -0800
Message-ID: <20170130204143.539-5-f.fainelli@gmail.com>
References: <20170130204143.539-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36209 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754449AbdA3UtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:49:20 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so24056300pfo.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 12:48:59 -0800 (PST)
In-Reply-To: <20170130204143.539-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use b53_mirror_add and b53_mirror_del because the Starfighter 2
is register compatible in that specific case.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index be282b430c50..2be963252ca5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1047,6 +1047,8 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_fdb_del		= b53_fdb_del,
 	.get_rxnfc		= bcm_sf2_get_rxnfc,
 	.set_rxnfc		= bcm_sf2_set_rxnfc,
+	.port_mirror_add	= b53_mirror_add,
+	.port_mirror_del	= b53_mirror_del,
 };
 
 struct bcm_sf2_of_data {
-- 
2.9.3
