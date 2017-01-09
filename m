From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v2 12/13] net: ethernet: aquantia: Receive side scaling
Date: Mon,  9 Jan 2017 14:16:10 -0800
Message-ID: <703b9184b3216032657a7895bd71929d2031bbc4.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:42634 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933128AbdAIWRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:17:23 -0500
In-Reply-To: <cover.1483999588.git.vomlehn@texas.net>
In-Reply-To: <2a2056f13b975c8a4924b4f733d3cdc28a6b9422.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net> <0b0d8974bdbfa66ab3bc4460f32f7916dd54b85a.1483999588.git.vomlehn@texas.net> <6d32f594bb99a6f56f82f13f6aa54885a06b1e22.1483999588.git.vomlehn@texas.net> <6dfadde2e1fe39b46d814c83fb7460566e860095.1483999588.git.vomlehn@texas.net> <a24ccb1c19a30c6fd4492b54d32663225d0f6534.1483999588.git.vomlehn@texas.net> <8b8385cb2a8e856da001922d65009a4fcfc26295.1483999588.git.vomlehn@texas.net> <1ea4ddc9bb144b5809aec4e441d553ff3fe9c263.1483999588.git.vomlehn@texas.net> <5cf2494bfdb3e327dec2fdc7c50ae56fdac83a2f.1483999588.git.vomlehn@texas.net> <68bda8ddca6d16001ea990a5197cdcdaa4efa107.1483999588.git.vomlehn@texas.net> <c2d259cedda86684baf77e04c83ea675ee040bda.1483999588.git.vomlehn@texas.net> <7bc5005bb4345003d27e67df218fd4689aca0050.1483999588.git.vomleh
 n@texas.net> <2a2056f13b975c8a4924b4f733d3cdc28a6b9422.1483999588.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add definitions that support receive side scaling.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/aq_rss.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_rss.h

diff --git a/drivers/net/ethernet/aquantia/aq_rss.h b/drivers/net/ethernet/aquantia/aq_rss.h
new file mode 100644
index 0000000..5869844
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_rss.h
@@ -0,0 +1,27 @@
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
+
-- 
2.7.4
