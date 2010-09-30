From: xiaohui.xin@intel.com
Subject: [PATCH v12 13/17] Add a kconfig entry and make entry for mp device.
Date: Thu, 30 Sep 2010 22:04:29 +0800
Message-ID: <a77e19e8a86f6754d4961a1128834cb98402966c.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30013 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756312Ab0I3NrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 09:47:12 -0400
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 drivers/vhost/Kconfig  |   10 ++++++++++
 drivers/vhost/Makefile |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
index e4e2fd1..a6b8cbf 100644
--- a/drivers/vhost/Kconfig
+++ b/drivers/vhost/Kconfig
@@ -9,3 +9,13 @@ config VHOST_NET
 	  To compile this driver as a module, choose M here: the module will
 	  be called vhost_net.
 
+config MEDIATE_PASSTHRU
+	tristate "mediate passthru network driver (EXPERIMENTAL)"
+	depends on VHOST_NET
+	---help---
+	  zerocopy network I/O support, we call it as mediate passthru to
+	  be distiguish with hardare passthru.
+
+	  To compile this driver as a module, choose M here: the module will
+	  be called mpassthru.
+
diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index 72dd020..c18b9fc 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_VHOST_NET) += vhost_net.o
 vhost_net-y := vhost.o net.o
+
+obj-$(CONFIG_MEDIATE_PASSTHRU) += mpassthru.o
-- 
1.7.3

