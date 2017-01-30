From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 4/4] net: dsa: bcm_sf2: Add support for port mirroring
Date: Sun, 29 Jan 2017 20:30:26 -0800
Message-ID: <20170130043026.28867-5-f.fainelli@gmail.com>
References: <20170130043026.28867-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35415 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdA3Eam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:30:42 -0500
Received: by mail-qk0-f193.google.com with SMTP id u25so17137461qki.2
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:30:41 -0800 (PST)
In-Reply-To: <20170130043026.28867-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use b53_mirror_add and b53_mirror_del because the Starfighter 2
is register compatible in that specific case.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8eecfd227e06..3e514d7af218 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1036,6 +1036,8 @@ static const struct dsa_switch_ops bcm_sf2_ops = {
 	.port_fdb_dump		= b53_fdb_dump,
 	.port_fdb_add		= b53_fdb_add,
 	.port_fdb_del		= b53_fdb_del,
+	.port_mirror_add	= b53_mirror_add,
+	.port_mirror_del	= b53_mirror_del,
 };
 
 struct bcm_sf2_of_data {
-- 
2.9.3
