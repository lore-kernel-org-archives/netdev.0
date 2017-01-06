From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v2 12/12] net: ethernet: aquantia: Receive side scaling
Date: Fri,  6 Jan 2017 00:06:13 -0800
Message-ID: <22b9276ab1020a75c13aa2714922434886446d69.1483689029.git.vomlehn@texas.net>
References: <cover.1483689029.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda4.aus1.datafoundry.com ([209.99.124.135]:60325 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S967053AbdAFIHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:07:07 -0500
In-Reply-To: <cover.1483689029.git.vomlehn@texas.net>
In-Reply-To: <b3222357373459bb1c5796dbb389aac7b22c466c.1483689029.git.vomlehn@texas.net>
References: <cover.1483689029.git.vomlehn@texas.net> <904a500ca838983102268d3c15d732cb138a5dd1.1483689029.git.vomlehn@texas.net> <41e24066f2a87cad644a902658846e109a6b406f.1483689029.git.vomlehn@texas.net> <7d0b8bdb9c3ec1d2cbfb136796dbfc66e0ab535d.1483689029.git.vomlehn@texas.net> <258c5f7206d65735020fb03113d47f1c2f00807d.1483689029.git.vomlehn@texas.net> <2c7a399a225633bb8cda2177a4581fb5cf154e2e.1483689029.git.vomlehn@texas.net> <dddb5f605411f83ca50b86537ed32bf4171d3159.1483689029.git.vomlehn@texas.net> <ea98248e0fbcbd2920585cbd40026c007e44865b.1483689029.git.vomlehn@texas.net> <d60f4ad644d065dcc8c0cf947ae30f29742023cd.1483689029.git.vomlehn@texas.net> <b7030db41714665ed35d1be58a4c1f14e5978e3a.1483689029.git.vomlehn@texas.net> <63e607a320c6874ae16ca7e5af354ea7d71d785b.1483689029.git.vomleh
 n@texas.net> <b3222357373459bb1c5796dbb389aac7b22c466c.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add definitions that support receive side scaling.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/aq_rss.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_rss.h

diff --git a/drivers/net/ethernet/aquantia/aq_rss.h b/drivers/net/ethernet/aquantia/aq_rss.h
new file mode 100644
index 0000000..250fce5
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_rss.h
@@ -0,0 +1,26 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2016 aQuantia Corporation. All rights reserved
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
