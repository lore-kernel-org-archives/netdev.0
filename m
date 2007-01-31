From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 6/10] cxgb3 - white space to tabs
Date: Tue, 30 Jan 2007 19:44:13 -0800
Message-ID: <20070131034413.8629.55529.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:26243 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932755AbXAaDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 22:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Use tabs in comments.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 7112bac..35a7fab 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -14,21 +14,21 @@
 #include "sge_defs.h"
 #include "firmware_exports.h"
 
- /**
-  *	t3_wait_op_done_val - wait until an operation is completed
-  *	@adapter: the adapter performing the operation
-  *	@reg: the register to check for completion
-  *	@mask: a single-bit field within @reg that indicates completion
-  *	@polarity: the value of the field when the operation is completed
-  *	@attempts: number of check iterations
-  *	@delay: delay in usecs between iterations
-  *	@valp: where to store the value of the register at completion time
-  *
-  *	Wait until an operation is completed by checking a bit in a register
-  *	up to @attempts times.  If @valp is not NULL the value of the register
-  *	at the time it indicated completion is stored there.  Returns 0 if the
-  *	operation completes and -EAGAIN otherwise.
-  */
+/**
+ *	t3_wait_op_done_val - wait until an operation is completed
+ *	@adapter: the adapter performing the operation
+ *	@reg: the register to check for completion
+ *	@mask: a single-bit field within @reg that indicates completion
+ *	@polarity: the value of the field when the operation is completed
+ *	@attempts: number of check iterations
+ *	@delay: delay in usecs between iterations
+ *	@valp: where to store the value of the register at completion time
+ *
+ *	Wait until an operation is completed by checking a bit in a register
+ *	up to @attempts times.  If @valp is not NULL the value of the register
+ *	at the time it indicated completion is stored there.  Returns 0 if the
+ *	operation completes and -EAGAIN otherwise.
+ */
 
 int t3_wait_op_done_val(struct adapter *adapter, int reg, u32 mask,
 			int polarity, int attempts, int delay, u32 *valp)
