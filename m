From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v2 net-next 01/13] ACPI: bus: add stub acpi_dev_found() to linux/acpi.h
Date: Mon, 30 May 2016 10:10:10 +0800
Message-ID: <1464574222-69608-2-git-send-email-yankejian@huawei.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:15966 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbcE3B6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 21:58:33 -0400
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

acpi_dev_found() will be used to detect if a given ACPI device is in the
system. It will be compiled in non-ACPI case, but the function is in
acpi_bus.h and acpi_bus.h can only be used in ACPI case, so this patch add
the stub function to linux/acpi.h to make compiled successfully in
non-ACPI cases.

Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 include/linux/acpi.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 288fac5..3025d19 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -543,6 +543,11 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *);
 
 struct fwnode_handle;
 
+static inline bool acpi_dev_found(const char *hid)
+{
+	return false;
+}
+
 static inline bool is_acpi_node(struct fwnode_handle *fwnode)
 {
 	return false;
-- 
1.9.1
