From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v5 12/13] net: ethernet: aquantia: Receive side scaling
Date: Thu, 12 Jan 2017 21:02:28 -0800
Message-ID: <c54a5830be99bc8f7ecbb4408bbc6b979b056c6a.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:53728 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751111AbdAMFD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 00:03:29 -0500
In-Reply-To: <cover.1484283610.git.vomlehn@texas.net>
In-Reply-To: <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net> <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net> <2c056fd544958594f6356a17892c251ea26ea8c8.1484283610.git.vomlehn@texas.net> <98a7a3c6800c246753ef6cfaa5982a348da757c8.1484283610.git.vomlehn@texas.net> <29b795c8c4fc8de7925e82e071e5feaa266cd801.1484283610.git.vomlehn@texas.net> <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net> <e17f53f9485f69edafa966d2bcbaa4b9fd7c145f.1484283610.git.vomlehn@texas.net> <e3f7eda0cc3bfa3426932c39465971ba4c6226ef.1484283610.git.vomlehn@texas.net> <2889e8e87b8b89945f34e57a7f8ca253f204de47.1484283610.git.vomlehn@texas.net> <fef6ab77998a2914f94549367b88ab31e1f734e7.1484283610.git.vomlehn@texas.net> <bd4244af243c5800bd08cfe6c3859f1b406089be.1484283610.git.vomleh
 n@texas.net> <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net>
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
 drivers/net/ethernet/aquantia/aq_rss.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_rss.h

diff --git a/drivers/net/ethernet/aquantia/aq_rss.h b/drivers/net/ethernet/aquantia/aq_rss.h
new file mode 100644
index 0000000..1db6eb2
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_rss.h
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
2.7.4
