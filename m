From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 1/5] device property: helper macros for property entry creation
Date: Wed,  5 Aug 2015 16:39:03 +0300
Message-ID: <1438781947-7952-2-git-send-email-heikki.krogerus@linux.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcos for easier creation of build-in property entries.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 include/linux/property.h | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/property.h b/include/linux/property.h
index 76ebde9..204d899 100644
--- a/include/linux/property.h
+++ b/include/linux/property.h
@@ -152,6 +152,41 @@ struct property_entry {
 	} value;
 };
 
+#define PROP_ENTRY_U8(_name_, _val_) { \
+	.name = _name_, \
+	.type = DEV_PROP_U8, \
+	.nval = 1, \
+	.value.u8_data = _val_, \
+}
+
+#define PROP_ENTRY_U16(_name_, _val_) { \
+	.name = _name_, \
+	.type = DEV_PROP_U16, \
+	.nval = 1, \
+	.value.u16_data = _val_, \
+}
+
+#define PROP_ENTRY_U32(_name_, _val_) { \
+	.name = _name_, \
+	.type = DEV_PROP_U32, \
+	.nval = 1, \
+	.value.u32_data = _val_, \
+}
+
+#define PROP_ENTRY_U64(_name_, _val_) { \
+	.name = _name_, \
+	.type = DEV_PROP_U64, \
+	.nval = 1, \
+	.value.u64_data = _val_, \
+}
+
+#define PROP_ENTRY_STRING(_name_, _val_) { \
+	.name = _name_, \
+	.type = DEV_PROP_STRING, \
+	.nval = 1, \
+	.value.str = (const char **)_val_, \
+}
+
 /**
  * struct property_set - Collection of "built-in" device properties.
  * @fwnode: Handle to be pointed to by the fwnode field of struct device.
-- 
2.4.6
