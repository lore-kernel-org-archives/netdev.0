From: xiaohui.xin@intel.com
Subject: [PATCH v11 05/17] Add a function to indicate if device use external buffer.
Date: Sat, 25 Sep 2010 12:27:23 +0800
Message-ID: <8321171ad0747af27841311f7a6525d3bb9e2441.1285385607.git.xiaohui.xin@intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5f192de..23d6ec0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1602,6 +1602,11 @@ extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 extern int netdev_mp_port_prep(struct net_device *dev,
 				struct mpassthru_port *port);
 
+static inline bool dev_is_mpassthru(struct net_device *dev)
+{
+	return dev && dev->mp_port;
+}
+
 static inline void napi_free_frags(struct napi_struct *napi)
 {
 	kfree_skb(napi->skb);
-- 
1.7.3
