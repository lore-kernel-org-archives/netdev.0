From: Adit Ranadive <aditr@vmware.com>
Subject: [PATCH v4 15/16] IB: Add PVRDMA driver
Date: Sun, 11 Sep 2016 21:49:25 -0700
Message-ID: <1473655766-31628-16-git-send-email-aditr@vmware.com>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Adit Ranadive <aditr@vmware.com>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <jhansen@vmware.com>,
        <asarwade@vmware.com>, <georgezhang@vmware.com>,
        <bryantan@vmware.com>
To: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:38056 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932609AbcILEuv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 00:50:51 -0400
In-Reply-To: <1473655766-31628-1-git-send-email-aditr@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the InfiniBand subsystem to build the PVRDMA driver.

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: George Zhang <georgezhang@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
Reviewed-by: Bryan Tan <bryantan@vmware.com>
Signed-off-by: Adit Ranadive <aditr@vmware.com>
---
 drivers/infiniband/Kconfig     | 1 +
 drivers/infiniband/hw/Makefile | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 19a418a..dff4bcf 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -88,5 +88,6 @@ source "drivers/infiniband/sw/rdmavt/Kconfig"
 source "drivers/infiniband/sw/rxe/Kconfig"
 
 source "drivers/infiniband/hw/hfi1/Kconfig"
+source "drivers/infiniband/hw/pvrdma/Kconfig"
 
 endif # INFINIBAND
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index 21fe401..c8a7a36 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -10,3 +10,4 @@ obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
 obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
 obj-$(CONFIG_INFINIBAND_HFI1)		+= hfi1/
 obj-$(CONFIG_INFINIBAND_HNS)		+= hns/
+obj-$(CONFIG_INFINIBAND_PVRDMA)		+= pvrdma/
-- 
2.7.4
