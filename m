From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 7/9] net/inetdevice: inet_ifa_match can be boolean
Date: Thu,  8 Oct 2015 21:29:00 +0800
Message-ID: <1444310942-4428-8-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes inet_ifa_match return bool due to this
particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/inetdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a4328ce..3b0999e 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -171,7 +171,7 @@ __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
 			 __be32 local, int scope);
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 				    __be32 mask);
-static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
+static __inline__ bool inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
 }
-- 
1.9.1
