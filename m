From: xiaohui.xin@intel.com
Subject: [PATCH v13 13/16] Add a kconfig entry and make entry for mp device.
Date: Fri, 15 Oct 2010 17:12:14 +0800
Message-ID: <2b102c4de5cbd9753656450b97d1eff7e1a2b666.1287132437.git.xiaohui.xin@intel.com>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

