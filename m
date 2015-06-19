From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] ssb: remove unncessary out label
Date: Fri, 19 Jun 2015 14:23:45 +0530
Message-ID: <1434704025-20448-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: m@bues.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes unnecessary label "out" and
some restructring for using device_create_file directly.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Rohit Thapliyal <r.thapliyal@samsung.com>
---
 drivers/ssb/pci.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index 0f28c08..d6ca4d3 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -1173,17 +1173,11 @@ void ssb_pci_exit(struct ssb_bus *bus)
 int ssb_pci_init(struct ssb_bus *bus)
 {
 	struct pci_dev *pdev;
-	int err;
 
 	if (bus->bustype != SSB_BUSTYPE_PCI)
 		return 0;
 
 	pdev = bus->host_pci;
 	mutex_init(&bus->sprom_mutex);
-	err = device_create_file(&pdev->dev, &dev_attr_ssb_sprom);
-	if (err)
-		goto out;
-
-out:
-	return err;
+	return device_create_file(&pdev->dev, &dev_attr_ssb_sprom);
 }
-- 
1.7.1
