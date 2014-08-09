From: Ankit <learnertilldeath@gmail.com>
Subject: [PATCH] drivers: fixed spelling of "celcius" to "celsius"
Date: Sat,  9 Aug 2014 17:02:32 +0900
Message-ID: <1407571352-33867-1-git-send-email-learnertilldeath@gmail.com>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pm@vger.kernel.org,
	Ankit <learnertilldeath@gmail.com>
To: airlied@linux.ie, shahed.shaikh@qlogic.com, sre@kernel.org,
	dbaryshkov@gmail.com, dwmw2@infradead.org, rui.zhang@intel.com,
	edubezval@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed spelling issue -- changed celcius to celsius

Kernel version: mainline

Signed-off-by: Ankit <learnertilldeath@gmail.com>
---
 drivers/gpu/drm/nouveau/core/engine/graph/nv10.c  | 4 ++--
 drivers/gpu/drm/nouveau/core/engine/graph/nv20.c  | 2 +-
 drivers/gpu/drm/nouveau/core/engine/graph/nv25.c  | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 +-
 drivers/power/ds2780_battery.c                    | 2 +-
 drivers/power/ds2782_battery.c                    | 2 +-
 drivers/thermal/thermal_core.c                    | 2 +-
 7 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c b/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
index 4532f7e..1faeeb1 100644
--- a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
+++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
@@ -451,7 +451,7 @@ nv10_graph_sclass[] = {
 	{ 0x0093, &nv04_graph_ofuncs }, /* surf3d */
 	{ 0x0094, &nv04_graph_ofuncs }, /* ttri */
 	{ 0x0095, &nv04_graph_ofuncs }, /* mtri */
-	{ 0x0056, &nv04_graph_ofuncs }, /* celcius */
+	{ 0x0056, &nv04_graph_ofuncs }, /* celsius */
 	{},
 };
 
@@ -474,7 +474,7 @@ nv15_graph_sclass[] = {
 	{ 0x0093, &nv04_graph_ofuncs }, /* surf3d */
 	{ 0x0094, &nv04_graph_ofuncs }, /* ttri */
 	{ 0x0095, &nv04_graph_ofuncs }, /* mtri */
-	{ 0x0096, &nv04_graph_ofuncs }, /* celcius */
+	{ 0x0096, &nv04_graph_ofuncs }, /* celsius */
 	{},
 };
 
diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c b/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
index d145e08..eb00689 100644
--- a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
+++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
@@ -31,7 +31,7 @@ nv20_graph_sclass[] = {
 	{ 0x0072, &nv04_graph_ofuncs, NULL }, /* beta4 */
 	{ 0x0089, &nv04_graph_ofuncs, NULL }, /* sifm */
 	{ 0x008a, &nv04_graph_ofuncs, NULL }, /* ifc */
-	{ 0x0096, &nv04_graph_ofuncs, NULL }, /* celcius */
+	{ 0x0096, &nv04_graph_ofuncs, NULL }, /* celsius */
 	{ 0x0097, &nv04_graph_ofuncs, NULL }, /* kelvin */
 	{ 0x009e, &nv04_graph_ofuncs, NULL }, /* swzsurf */
 	{ 0x009f, &nv04_graph_ofuncs, NULL }, /* imageblit */
diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c b/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
index 7a80d00..fcfe1c5 100644
--- a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
+++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
@@ -28,7 +28,7 @@ nv25_graph_sclass[] = {
 	{ 0x0072, &nv04_graph_ofuncs, NULL }, /* beta4 */
 	{ 0x0089, &nv04_graph_ofuncs, NULL }, /* sifm */
 	{ 0x008a, &nv04_graph_ofuncs, NULL }, /* ifc */
-	{ 0x0096, &nv04_graph_ofuncs, NULL }, /* celcius */
+	{ 0x0096, &nv04_graph_ofuncs, NULL }, /* celsius */
 	{ 0x009e, &nv04_graph_ofuncs, NULL }, /* swzsurf */
 	{ 0x009f, &nv04_graph_ofuncs, NULL }, /* imageblit */
 	{ 0x0597, &nv04_graph_ofuncs, NULL }, /* kelvin */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index f5786d5..b0f7ab0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1264,7 +1264,7 @@ static ssize_t qlcnic_hwmon_show_temp(struct device *dev,
 		value = QLC_SHARED_REG_RD32(adapter, QLCNIC_ASIC_TEMP);
 
 	temperature = qlcnic_get_temp_val(value);
-	/* display millidegree celcius */
+	/* display millidegree celsius */
 	temperature *= 1000;
 	return sprintf(buf, "%u\n", temperature);
 }
diff --git a/drivers/power/ds2780_battery.c b/drivers/power/ds2780_battery.c
index 9f418fa..bf7d4bd 100644
--- a/drivers/power/ds2780_battery.c
+++ b/drivers/power/ds2780_battery.c
@@ -210,7 +210,7 @@ static int ds2780_get_temperature(struct ds2780_device_info *dev_info,
 		return ret;
 
 	/*
-	 * Temperature is measured in units of 0.125 degrees celcius, the
+	 * Temperature is measured in units of 0.125 degrees celsius, the
 	 * power_supply class measures temperature in tenths of degrees
 	 * celsius. The temperature value is stored as a 10 bit number, plus
 	 * sign in the upper bits of a 16 bit register.
diff --git a/drivers/power/ds2782_battery.c b/drivers/power/ds2782_battery.c
index 041f9b6..adc7d32 100644
--- a/drivers/power/ds2782_battery.c
+++ b/drivers/power/ds2782_battery.c
@@ -104,7 +104,7 @@ static int ds278x_get_temp(struct ds278x_info *info, int *temp)
 	int err;
 
 	/*
-	 * Temperature is measured in units of 0.125 degrees celcius, the
+	 * Temperature is measured in units of 0.125 degrees celsius, the
 	 * power_supply class measures temperature in tenths of degrees
 	 * celsius. The temperature value is stored as a 10 bit number, plus
 	 * sign in the upper bits of a 16 bit register.
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 71b0ec0..e69db4f 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -691,7 +691,7 @@ passive_store(struct device *dev, struct device_attribute *attr,
 	if (!sscanf(buf, "%d\n", &state))
 		return -EINVAL;
 
-	/* sanity check: values below 1000 millicelcius don't make sense
+	/* sanity check: values below 1000 millicelsius don't make sense
 	 * and can cause the system to go into a thermal heart attack
 	 */
 	if (state && state < 1000)
-- 
1.8.3.4 (Apple Git-47)
