From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qede: fix typo in qede_rdma_dev_add declaration
Date: Wed, 21 Jun 2017 23:59:41 +0200
Message-ID: <20170621220004.4073594-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ram Amrani <Ram.Amrani@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An extraneous semicolon crept in, causing a build failure:

In file included from /git/arm-soc/drivers/net/ethernet/qlogic/qede/qede.h:43:0,
                 from /git/arm-soc/drivers/net/ethernet/qlogic/qede/qede_main.c:63:
include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token

Fixes: bbfcd1e8e167 ("qed*: Set rdma generic functions prefix")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
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
2.9.0
