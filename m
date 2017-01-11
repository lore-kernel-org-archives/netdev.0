From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/13] s390/qeth: Remove QETH_IP_HEADER_SIZE
Date: Wed, 11 Jan 2017 12:55:52 +0100
Message-ID: <20170111115600.4524-6-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Remove unused define QETH_IP_HEADER_SIZE.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 41e4665..774ae51 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -281,8 +281,6 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_HIGH_WATERMARK_PACK 5
 #define QETH_WATERMARK_PACK_FUZZ 1
 
-#define QETH_IP_HEADER_SIZE 40
-
 /* large receive scatter gather copy break */
 #define QETH_RX_SG_CB (PAGE_SIZE >> 1)
 #define QETH_RX_PULL_LEN 256
-- 
2.8.4
