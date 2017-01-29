From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH stable v1 12/13] net: ethernet: aquantia: Receive side scaling
Date: Sat, 28 Jan 2017 21:09:12 -0800
Message-ID: <e91f312513cbaf35000919e239b41d4f351c4f95.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:38103 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751819AbdA2Fp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 00:45:26 -0500
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add definitions that support receive side scaling.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/aq_rss.h | 26 +++++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_rss.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_rss.h b/drivers/net/ethernet/aquantia/atlantic/aq_rss.h
new file mode 100644
index 0000000..1db6eb2
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_rss.h
@@ -0,0 +1,26 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_rss.h: Receive Side Scaling definitions. */
+
+#ifndef AQ_RSS_H
+#define AQ_RSS_H
+
+#include "aq_common.h"
+#include "aq_cfg.h"
+
+struct aq_rss_parameters {
+	u16 base_cpu_number;
+	u16 indirection_table_size;
+	u16 hash_secret_key_size;
+	u32 hash_secret_key[AQ_CFG_RSS_HASHKEY_SIZE / sizeof(u32)];
+	u8 indirection_table[AQ_CFG_RSS_INDIRECTION_TABLE_MAX];
+};
+
+#endif /* AQ_RSS_H */
-- 
2.9.3
