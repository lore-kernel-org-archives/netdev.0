From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v2 net-next 02/13] ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
Date: Mon, 30 May 2016 10:10:11 +0800
Message-ID: <1464574222-69608-3-git-send-email-yankejian@huawei.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <andriy.shevchenko@linux.intel.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 3025d19..4d4bb49 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -659,6 +659,14 @@ static inline bool acpi_driver_match_device(struct device *dev,
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

