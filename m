From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v5 14/16] IB/pvrdma: Add Kconfig and Makefile
Date: Sat, 24 Sep 2016 16:21:38 -0700
Message-ID: <9ddd44d8ec8b80e90cf8d235624d0feb37328d15.1474759181.git.aditr@vmware.com>
References: <cover.1474759181.git.aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:24765 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932811AbcIXXXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 19:23:03 -0400
In-Reply-To: <cover.1474759181.git.aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a Kconfig and Makefile for the PVRDMA driver.

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: George Zhang <georgezhang@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
Reviewed-by: Bryan Tan <bryantan@vmware.com>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
Changes v3->v4:
 - Enforced dependency on VMXNet3
---
 drivers/infiniband/hw/pvrdma/Kconfig  | 7 +++++++
 drivers/infiniband/hw/pvrdma/Makefile | 3 +++
 2 files changed, 10 insertions(+)
 create mode 100644 drivers/infiniband/hw/pvrdma/Kconfig
 create mode 100644 drivers/infiniband/hw/pvrdma/Makefile

diff --git a/drivers/infiniband/hw/pvrdma/Kconfig b/drivers/infiniband/hw/pvrdma/Kconfig
new file mode 100644
index 0000000..b345679
--- /dev/null
+++ b/drivers/infiniband/hw/pvrdma/Kconfig
@@ -0,0 +1,7 @@
+config INFINIBAND_PVRDMA
+	tristate "VMware Paravirtualized RDMA Driver"
+	depends on NETDEVICES && ETHERNET && PCI && INET && VMXNET3
+	---help---
+	  This driver provides low-level support for VMware Paravirtual
+	  RDMA adapter. It interacts with the VMXNet3 driver to provide
+	  Ethernet capabilities.
diff --git a/drivers/infiniband/hw/pvrdma/Makefile b/drivers/infiniband/hw/pvrdma/Makefile
new file mode 100644
index 0000000..e6f078b
--- /dev/null
+++ b/drivers/infiniband/hw/pvrdma/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_INFINIBAND_PVRDMA) += pvrdma.o
+
+pvrdma-y := pvrdma_cmd.o pvrdma_cq.o pvrdma_doorbell.o pvrdma_main.o pvrdma_misc.o pvrdma_mr.o pvrdma_qp.o pvrdma_verbs.o
-- 
2.7.4
