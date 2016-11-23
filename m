From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH v3] net: dsa: mv88e6xxx: enable EDSA on mv88e6097
Date: Wed, 23 Nov 2016 18:11:35 +0100
Message-ID: <20161123171135.9768-1-stefan.eichenberger@netmodule.com>
References: <20161123165949.GB8760@lunn.ch>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36639 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756301AbcKWRMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:12:12 -0500
Received: by mail-wj0-f196.google.com with SMTP id jb2so1488114wjb.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 09:12:11 -0800 (PST)
In-Reply-To: <20161123165949.GB8760@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EDSA is currently disabled on mv88e6097 devices, this commit enables it.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index ab52c37..a2ff1fc 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -543,7 +543,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_G1_ATU_FID |	\
+	(MV88E6XXX_FLAG_EDSA |		\
+	 MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-- 
2.9.3
