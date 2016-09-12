From: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 14/16] IB/pvrdma: Add Kconfig and Makefile
Date: Sun, 11 Sep 2016 21:49:24 -0700
Message-ID: <1473655766-31628-15-git-send-email-aditr@vmware.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
        <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <pv-drivers-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473655766-31628-1-git-send-email-aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a Kconfig and Makefile for the PVRDMA driver.

Reviewed-by: Jorgen Hansen <jhansen-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Reviewed-by: George Zhang <georgezhang-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Reviewed-by: Aditya Sarwade <asarwade-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Reviewed-by: Bryan Tan <bryantan-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Adit Ranadive <aditr-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
