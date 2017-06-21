From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] qed*: Fix build for !QED_RDMA
Date: Wed, 21 Jun 2017 11:45:31 +0100
Message-ID: <20170621104531.11071-1-broonie@kernel.org>
Cc: netdev@vger.kernel.org, everest-linux-l2@cavium.com,
        Mark Brown <broonie@kernel.org>
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:51050 "EHLO
        mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdFUKpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 06:45:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A stray semicolon was introduced by bbfcd1e8e1677b (qed*: Set rdma
generic functions prefix), remove it.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 include/linux/qed/qede_rdma.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/qed/qede_rdma.h b/include/linux/qed/qede_rdma.h
index 1348a16e5e4b..9904617a9730 100644
--- a/include/linux/qed/qede_rdma.h
+++ b/include/linux/qed/qede_rdma.h
@@ -81,7 +81,7 @@ void qede_rdma_dev_remove(struct qede_dev *dev);
 void qede_rdma_event_changeaddr(struct qede_dev *edr);
 
 #else
-static inline int qede_rdma_dev_add(struct qede_dev *dev);
+static inline int qede_rdma_dev_add(struct qede_dev *dev)
 {
 	return 0;
 }
-- 
2.11.0
