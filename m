From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Move firmware version MACRO to t4fw_version.h
Date: Tue, 27 Jan 2015 20:12:52 +0530
Message-ID: <1422369772-2215-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27006 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751501AbbA0Oho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:37:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move firmware version MACRO to a new t4fw_version.h file so that csiostor driver
can also use it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |   10 ----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h |   48 +++++++++++++++++++++
 3 files changed, 49 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d98a446..fb6980a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -49,16 +49,6 @@
 #include <asm/io.h>
 #include "cxgb4_uld.h"
 
-#define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0C
-#define T4FW_VERSION_MICRO 0x19
-#define T4FW_VERSION_BUILD 0x00
-
-#define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0C
-#define T5FW_VERSION_MICRO 0x19
-#define T5FW_VERSION_BUILD 0x00
-
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c27dcd9..5bf490a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -70,6 +70,7 @@
 #include "t4_values.h"
 #include "t4_msg.h"
 #include "t4fw_api.h"
+#include "t4fw_version.h"
 #include "cxgb4_dcb.h"
 #include "cxgb4_debugfs.h"
 #include "clip_tbl.h"
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
new file mode 100644
index 0000000..e2bd3f7
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -0,0 +1,48 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4FW_VERSION_H__
+#define __T4FW_VERSION_H__
+
+#define T4FW_VERSION_MAJOR 0x01
+#define T4FW_VERSION_MINOR 0x0C
+#define T4FW_VERSION_MICRO 0x19
+#define T4FW_VERSION_BUILD 0x00
+
+#define T5FW_VERSION_MAJOR 0x01
+#define T5FW_VERSION_MINOR 0x0C
+#define T5FW_VERSION_MICRO 0x19
+#define T5FW_VERSION_BUILD 0x00
+
+#endif
-- 
1.7.1
