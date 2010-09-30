From: xiaohui.xin@intel.com
Subject: [PATCH v12 05/17] Add a function to indicate if device use external buffer.
Date: Thu, 30 Sep 2010 22:04:22 +0800
Message-ID: <72e847e65da4e1b51adb288f5768e67eb8a3675f.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
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
index 27f5024..9ed4fa2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1611,6 +1611,11 @@ extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 extern int netdev_mp_port_prep(struct net_device *dev,
 				struct mp_port *port);
 
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
