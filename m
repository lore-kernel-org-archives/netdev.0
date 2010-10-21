From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/12] qlge: disable unsed dump code
Date: Thu, 21 Oct 2010 10:50:55 -0700
Message-ID: <20101021175148.934670209@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: David Miller <davem@davemloft.net>,
	Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36320 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756416Ab0JUSBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:06 -0400
Content-Disposition: inline; filename=qlge-dump.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has lots of unused code to dump data structures to
console.  Use existing simple way to remove the code with ifdef.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/qlge/qlge.h |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- a/drivers/net/qlge/qlge.h	2010-10-21 09:54:17.264568433 -0700
+++ b/drivers/net/qlge/qlge.h	2010-10-21 09:55:10.045930105 -0700
@@ -2243,14 +2243,12 @@ void ql_check_lb_frame(struct ql_adapter
 int ql_own_firmware(struct ql_adapter *qdev);
 int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget);
 
-#if 1
-#define QL_ALL_DUMP
-#define QL_REG_DUMP
-#define QL_DEV_DUMP
-#define QL_CB_DUMP
+/* #define QL_ALL_DUMP */
+/* #define QL_REG_DUMP */
+/* #define QL_DEV_DUMP */
+/* #define QL_CB_DUMP */
 /* #define QL_IB_DUMP */
 /* #define QL_OB_DUMP */
-#endif
 
 #ifdef QL_REG_DUMP
 extern void ql_dump_xgmac_control_regs(struct ql_adapter *qdev);


