From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v4 12/13] net: ethernet: aquantia: Receive side scaling
Date: Wed, 11 Jan 2017 19:53:16 -0800
Message-ID: <4f74abb3a4b2cab8acf0c6c5ddb5fffd0bf51be8.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:43860 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751163AbdALDyS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 22:54:18 -0500
In-Reply-To: <cover.1484192452.git.vomlehn@texas.net>
In-Reply-To: <b9cf8d650c93e1d827597c87d4928d98759736f7.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net> <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net> <20a9e54c90f44662be120d9c863a89f1ffe340e5.1484192452.git.vomlehn@texas.net> <6c34bc1f4f4a63732a5c6ac960eb78c55646be06.1484192452.git.vomlehn@texas.net> <317cced5b487a46d728e731f967bf6231ea453ec.1484192452.git.vomlehn@texas.net> <2287a0a40f4c507fa650ee2750d613c28fbb57a7.1484192452.git.vomlehn@texas.net> <b96fe90743466d671a2ac5a741118059cdeb5f1a.1484192452.git.vomlehn@texas.net> <14143df0838ee18962e5df714d31b683afe44077.1484192452.git.vomlehn@texas.net> <4218cb42d4819ff59f24b3a3b28d2621c549f202.1484192452.git.vomlehn@texas.net> <c3773612a6b9bef64addd3f88d3920ec8dd68daa.1484192452.git.vomlehn@texas.net> <868d6d2e2defa8a4d9d0dc66e575c8a7b64cc72b.1484192452.git.vomleh
 n@texas.net> <b9cf8d650c93e1d827597c87d4928d98759736f7.1484192452.git.vomlehn@texas.net>
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
