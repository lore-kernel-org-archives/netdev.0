From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/4] tipc: Use <linux/uaccess.h> instead of <asm/uaccess.h>
Date: Thu, 12 Dec 2013 09:36:41 +0800
Message-ID: <1386812202-11956-4-git-send-email-wangweidong1@huawei.com>
References: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:20873 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab3LLBg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:36:57 -0500
In-Reply-To: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As warned by checkpatch.pl, use #include <linux/uaccess.h>
instead of <asm/uaccess.h>

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/core.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 94895d4..1ff477b 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -47,7 +47,7 @@
 #include <linux/mm.h>
 #include <linux/timer.h>
 #include <linux/string.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/interrupt.h>
 #include <linux/atomic.h>
 #include <asm/hardirq.h>
-- 
1.7.12
