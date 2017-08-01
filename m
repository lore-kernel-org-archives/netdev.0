From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 2/2] atm: solos-pci: constify attribute_group structures
Date: Tue, 1 Aug 2017 19:57:47 -0400
Message-ID: <20170801235747.GA14034@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33648 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdHAX4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 19:56:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions working with attribute_groups provided by <linux/sysfs.h>
work with const attribute_group. These attribute_group structures do not
change at runtime so mark them as const.

File size before:
 text      data     bss     dec     hex filename
 35740    28424     832   64996    fde4 drivers/atm/solos-pci.o

File size after:
 text      data     bss     dec     hex filename
 35932    28232     832   64996    fde4 drivers/atm/solos-pci.o

This change was made with the help of Coccinelle.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/atm/solos-pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c8f2ca6..3f9c37d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -611,7 +611,7 @@ static struct attribute *solos_attrs[] = {
 	NULL
 };
 
-static struct attribute_group solos_attr_group = {
+static const struct attribute_group solos_attr_group = {
 	.attrs = solos_attrs,
 	.name = "parameters",
 };
@@ -628,7 +628,7 @@ static struct attribute *gpio_attrs[] = {
 	NULL
 };
 
-static struct attribute_group gpio_attr_group = {
+static const struct attribute_group gpio_attr_group = {
 	.attrs = gpio_attrs,
 	.name = "gpio",
 };
-- 
2.7.4
