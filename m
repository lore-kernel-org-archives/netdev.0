From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 6/9] ssb: use to_pci_dev()
Date: Sun, 27 Dec 2015 18:46:02 +0800
Message-ID: <b08d4f25c027f69f5bba4c8ffed79c83a5e5e684.1451211133.git.geliangtang@163.com>
References: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Buesch <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
In-Reply-To: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
References: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_pci_dev() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/ssb/pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index 0f28c08..67428f4 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -1130,7 +1130,7 @@ static ssize_t ssb_pci_attr_sprom_show(struct device *pcidev,
 				       struct device_attribute *attr,
 				       char *buf)
 {
-	struct pci_dev *pdev = container_of(pcidev, struct pci_dev, dev);
+	struct pci_dev *pdev = to_pci_dev(pcidev);
 	struct ssb_bus *bus;
 
 	bus = ssb_pci_dev_to_bus(pdev);
@@ -1144,7 +1144,7 @@ static ssize_t ssb_pci_attr_sprom_store(struct device *pcidev,
 					struct device_attribute *attr,
 					const char *buf, size_t count)
 {
-	struct pci_dev *pdev = container_of(pcidev, struct pci_dev, dev);
+	struct pci_dev *pdev = to_pci_dev(pcidev);
 	struct ssb_bus *bus;
 
 	bus = ssb_pci_dev_to_bus(pdev);
-- 
2.5.0
