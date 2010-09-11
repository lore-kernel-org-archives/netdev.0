From: xiaohui.xin@intel.com
Subject: [RFC PATCH v10 12/16] Add a kconfig entry and make entry for mp device.
Date: Sat, 11 Sep 2010 17:53:05 +0800
Message-ID: <1284198789-5358-13-git-send-email-xiaohui.xin@intel.com>
References: <1284198789-5358-1-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-2-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-3-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-4-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-5-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-6-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-7-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-8-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-9-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-10-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-11-git-send-email-xiaohui.xin@intel.com>
 <1284198789-5358-12-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50447 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab0IKJg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Sep 2010 05:36:59 -0400
In-Reply-To: <1284198789-5358-12-git-send-email-xiaohui.xin@intel.com>
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
1.5.4.4

