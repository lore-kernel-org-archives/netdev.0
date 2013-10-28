From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v2 3/3] net, iovec: fix the incorrect comment in memcpy_fromiovecend()
Date: Mon, 28 Oct 2013 14:01:50 +0800
Message-ID: <1382940110-10737-3-git-send-email-zwu.kernel@gmail.com>
References: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/iovec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/iovec.c b/net/core/iovec.c
index b77eeec..4cdb7c4 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -100,7 +100,7 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
 EXPORT_SYMBOL(memcpy_toiovecend);
 
 /*
- *	Copy iovec from kernel. Returns -EFAULT on error.
+ *	Copy iovec to kernel. Returns -EFAULT on error.
  */
 
 int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
-- 
1.7.11.7
