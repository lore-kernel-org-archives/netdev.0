From: guillaume1.gomez@gmail.com
Subject: [PATCH 1/1] net: Remove unneeded return from void function
Date: Wed, 23 Sep 2015 20:16:00 +0200
Message-ID: <1443032160-3164-1-git-send-email-guillaume1.gomez@gmail.com>
To: guillaume1.gomez@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Gomez <guillaume1.gomez@gmail.com>

Signed-off-by: Guillaume Gomez <guillaume1.gomez@gmail.com>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a0069..4a444a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -457,7 +457,7 @@ void napi_complete_done(struct napi_struct *n, int work_done);
  */
 static inline void napi_complete(struct napi_struct *n)
 {
-	return napi_complete_done(n, 0);
+	napi_complete_done(n, 0);
 }
 
 /**
-- 
1.9.1
