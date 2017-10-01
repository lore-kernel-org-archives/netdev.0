From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 4/5] net: dsa: bcm_sf2: Add support for LAG
Date: Sun,  1 Oct 2017 12:46:38 -0700
Message-ID: <20171001194639.8647-5-f.fainelli@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38754 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdJATqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:54 -0400
Received: by mail-oi0-f65.google.com with SMTP id s145so2115567oie.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:54 -0700 (PDT)
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the recently introduced b53 LAG operations and use those as-is.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 7aecc98d0a18..41a06fde7510 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -901,6 +901,9 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.set_rxnfc		= bcm_sf2_set_rxnfc,
 	.port_mirror_add	= b53_mirror_add,
 	.port_mirror_del	= b53_mirror_del,
+	.port_lag_member	= b53_lag_member,
+	.port_lag_join		= b53_lag_join,
+	.port_lag_leave		= b53_lag_leave,
 };
 
 struct bcm_sf2_of_data {
-- 
2.11.0
