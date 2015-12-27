From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 1/9] atm: solos-pci: use to_pci_dev()
Date: Sun, 27 Dec 2015 18:45:57 +0800
Message-ID: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-138.163.com ([123.125.50.138]:32922 "EHLO m50-138.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbbL0Kq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 05:46:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use to_pci_dev() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/atm/solos-pci.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 0c2b4ba0..6ac2b2b 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -525,7 +525,7 @@ struct geos_gpio_attr {
 static ssize_t geos_gpio_store(struct device *dev, struct device_attribute *attr,
 			       const char *buf, size_t count)
 {
-	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
 	struct solos_card *card = pci_get_drvdata(pdev);
 	uint32_t data32;
@@ -551,7 +551,7 @@ static ssize_t geos_gpio_store(struct device *dev, struct device_attribute *attr
 static ssize_t geos_gpio_show(struct device *dev, struct device_attribute *attr,
 			      char *buf)
 {
-	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
 	struct solos_card *card = pci_get_drvdata(pdev);
 	uint32_t data32;
@@ -565,7 +565,7 @@ static ssize_t geos_gpio_show(struct device *dev, struct device_attribute *attr,
 static ssize_t hardware_show(struct device *dev, struct device_attribute *attr,
 			     char *buf)
 {
-	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
 	struct solos_card *card = pci_get_drvdata(pdev);
 	uint32_t data32;
-- 
2.5.0
