From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [patch net-next 09/11] ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
Date: Fri, 13 May 2016 16:19:15 +0800
Message-ID: <1463127557-90824-10-git-send-email-Yisen.Zhuang@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

acpi_evaluate_dsm() will be used to handle the _DSM method in ACPI case.
It will be compiled in non-ACPI case, but the function is in acpi_bus.h
and acpi_bus.h can only be used in ACPI case, so this patch add the stub
function to linux/acpi.h to make compiled successfully in non-ACPI cases.

Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 include/linux/acpi.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index e578bce..5c5566e 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -661,6 +661,14 @@ static inline bool acpi_driver_match_device(struct device *dev,
 	return false;
 }
 
+static inline union acpi_object *acpi_evaluate_dsm(acpi_handle handle,
+						   const u8 *uuid,
+						   int rev, int func,
+						   union acpi_object *argv4)
+{
+	return NULL;
+}
+
 static inline int acpi_device_uevent_modalias(struct device *dev,
 				struct kobj_uevent_env *env)
 {
-- 
1.9.1
