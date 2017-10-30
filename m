From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH] ixgbe: Remove an obsolete comment about ITR.
Date: Mon, 30 Oct 2017 06:09:09 -0700
Message-ID: <1509368949-48105-1-git-send-email-zhangtonghao@didichuxing.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:56414 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdJ3NJR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 09:09:17 -0400
Received: by mail-pf0-f194.google.com with SMTP id b85so10967448pfj.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 06:09:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>

The InterruptThrottleRate has been removed from ixgbe. Then Update
the comment.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7f503d3..2a4ff0c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2534,8 +2534,6 @@ enum latency_range {
  *      based on theoretical maximum wire speed and thresholds were set based
  *      on testing data as well as attempting to minimize response time
  *      while increasing bulk throughput.
- *      this functionality is controlled by the InterruptThrottleRate module
- *      parameter (see ixgbe_param.c)
  **/
 static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
 			     struct ixgbe_ring_container *ring_container)
-- 
1.8.3.1
