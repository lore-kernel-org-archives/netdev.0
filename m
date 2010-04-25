From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v4 05/18] Add a function to indicate if device use external buffer.
Date: Sun, 25 Apr 2010 17:19:52 +0800
Message-ID: <1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2f9a4f2..a1a2aaf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1602,6 +1602,13 @@ extern void netdev_mp_port_detach(struct net_device *dev);
 int netdev_mp_port_prep(struct net_device *dev,
 			struct mpassthru_port *port);
 
+static int dev_is_mpassthru(struct net_device *dev)
+{
+	if (dev && dev->mp_port)
+		return 1;
+	return 0;
+}
+
 static inline void napi_free_frags(struct napi_struct *napi)
 {
 	kfree_skb(napi->skb);
-- 
1.5.4.4

