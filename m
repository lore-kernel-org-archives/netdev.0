From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next v2 1/2] net: dsa: mv88e6xxx: enable EDSA on mv88e6097
Date: Wed, 23 Nov 2016 21:59:51 +0100
Message-ID: <20161123205952.6231-2-stefan.eichenberger@netmodule.com>
References: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33166 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755376AbcKWVQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 16:16:37 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so3171248wmu.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 13:16:36 -0800 (PST)
In-Reply-To: <20161123205952.6231-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EDSA is currently disabled on mv88e6097 devices, this commit enables it.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9298faa..3e69526 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -541,7 +541,8 @@ enum mv88e6xxx_cap {
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
