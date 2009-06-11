From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Increase default TX/RX ring size to 1024.
Date: Wed, 10 Jun 2009 18:49:35 -0700
Message-ID: <1244684975-10211-3-git-send-email-ron.mercer@qlogic.com>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39442 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758623AbZFKB5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 21:57:06 -0400
In-Reply-To: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 156e02e..0c47bbe 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -36,11 +36,11 @@
 #define MAX_TX_RINGS MAX_CPUS
 #define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
 
-#define NUM_TX_RING_ENTRIES	256
-#define NUM_RX_RING_ENTRIES	256
+#define NUM_TX_RING_ENTRIES	1024
+#define NUM_RX_RING_ENTRIES	1024
 
-#define NUM_SMALL_BUFFERS   512
-#define NUM_LARGE_BUFFERS   512
+#define NUM_SMALL_BUFFERS   1024
+#define NUM_LARGE_BUFFERS   1024
 #define DB_PAGE_SIZE 4096
 
 /* Calculate the number of (4k) pages required to
-- 
1.6.0.2

