From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 4/5] qed: Remove the un-needed ptp header file.
Date: Wed, 26 Apr 2017 09:00:52 -0700
Message-ID: <20170426160053.8356-5-sudarsana.kalluru@cavium.com>
References: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0061.outbound.protection.outlook.com ([104.47.41.61]:33280
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752720AbdDZQBT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:19 -0400
In-Reply-To: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch deletes the qed_ptp.h file which is not required.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ptp.c |  1 -
 drivers/net/ethernet/qlogic/qed/qed_ptp.h | 47 -------------------------------
 2 files changed, 48 deletions(-)
 delete mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.h

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.c b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
index 26a9baf..c0a3cbd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ptp.c
@@ -35,7 +35,6 @@
 #include "qed_hw.h"
 #include "qed_l2.h"
 #include "qed_mcp.h"
-#include "qed_ptp.h"
 #include "qed_reg_addr.h"
 
 /* 16 nano second time quantas to wait before making a Drift adjustment */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ptp.h b/drivers/net/ethernet/qlogic/qed/qed_ptp.h
deleted file mode 100644
index 63c666d..0000000
--- a/drivers/net/ethernet/qlogic/qed/qed_ptp.h
+++ /dev/null
@@ -1,47 +0,0 @@
-/* QLogic qed NIC Driver
- * Copyright (c) 2015-2017  QLogic Corporation
- *
- * This software is available to you under a choice of one of two
- * licenses.  You may choose to be licensed under the terms of the GNU
- * General Public License (GPL) Version 2, available from the file
- * COPYING in the main directory of this source tree, or the
- * OpenIB.org BSD license below:
- *
- *     Redistribution and use in source and binary forms, with or
- *     without modification, are permitted provided that the following
- *     conditions are met:
- *
- *      - Redistributions of source code must retain the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer.
- *
- *      - Redistributions in binary form must reproduce the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer in the documentation and /or other materials
- *        provided with the distribution.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _QED_PTP_H
-#define _QED_PTP_H
-#include <linux/types.h>
-
-int qed_ptp_hwtstamp_tx_on(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
-int qed_ptp_cfg_rx_filters(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
-			   enum qed_ptp_filter_type type);
-int qed_ptp_read_rx_ts(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, u64 *ts);
-int qed_ptp_read_tx_ts(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, u64 *ts);
-int qed_ptp_read_cc(struct qed_hwfn *p_hwfn,
-		    struct qed_ptt *p_ptt, u64 *cycles);
-int qed_ptp_adjfreq(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt, s32 ppb);
-int qed_ptp_disable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
-int qed_ptp_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
-
-#endif
-- 
1.8.3.1
