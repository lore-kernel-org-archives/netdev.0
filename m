From: Amit Ghadge <amitg.b14@gmail.com>
Subject: [PATCH 2/2] net: Fix coding style warnings and errors.
Date: Tue, 17 May 2016 08:46:30 +0530
Message-ID: <1463454990-9723-1-git-send-email-amitg.b14@gmail.com>
Cc: linux-kernel@vger.kernel.org, Amit Ghadge <amitg.b14@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up checkpatch warnings and errors:

* WARNING: Block comments use * on subsequent lines
* WARNING: Missing a blank line after declarations
* WARNING: networking block comments don't use an empty /* line, use /*
* ERROR: code indent should use tabs where possible
* WARNING: please, no space before tabs
* WARNING: please, no spaces at the start of a line
* WARNING: line over 80 characters
* ERROR: space prohibited after that open parenthesis '('

Signed-off-by: Amit Ghadge <amitg.b14@gmail.com>
---
 drivers/net/Space.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 67977f1..b5e92a6 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -35,8 +35,8 @@
 #include <net/Space.h>
 
 /* A unified ethernet device probe.  This is the easiest way to have every
-   ethernet adaptor have the name "eth[0123...]".
-   */
+ * ethernet adaptor have the name "eth[0123...]".
+ */
 
 struct devprobe2 {
 	struct net_device *(*probe)(int unit);
@@ -46,6 +46,7 @@ struct devprobe2 {
 static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
 {
 	struct net_device *dev;
+
 	for (; p->probe; p++) {
 		if (autoprobe && p->status)
 			continue;
@@ -58,8 +59,7 @@ static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
 	return -ENODEV;
 }
 
-/*
- * ISA probes that touch addresses < 0x400 (including those that also
+/*ISA probes that touch addresses < 0x400 (including those that also
  * look for EISA/PCI cards in addition to ISA cards).
  */
 static struct devprobe2 isa_probes[] __initdata = {
@@ -86,11 +86,11 @@ static struct devprobe2 isa_probes[] __initdata = {
 #endif
 #ifdef CONFIG_CS89x0
 #ifndef CONFIG_CS89x0_PLATFORM
- 	{cs89x0_probe, 0},
+	{cs89x0_probe, 0},
 #endif
 #endif
-#if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
-	{i82596_probe, 0},
+#if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel */
+	{i82596_probe, 0},					/* I82596 */
 #endif
 #ifdef CONFIG_NI65
 	{ni65_probe, 0},
@@ -118,13 +118,12 @@ static struct devprobe2 m68k_probes[] __initdata = {
 	{mac8390_probe, 0},
 #endif
 #ifdef CONFIG_MAC89x0
- 	{mac89x0_probe, 0},
+	{mac89x0_probe, 0},
 #endif
 	{NULL, 0},
 };
 
-/*
- * Unified ethernet device probe, segmented per architecture and
+/* Unified ethernet device probe, segmented per architecture and
  * per bus interface. This drives the legacy devices only for now.
  */
 
@@ -135,7 +134,7 @@ static void __init ethif_probe2(int unit)
 	if (base_addr == 1)
 		return;
 
-	(void)(	probe_list2(unit, m68k_probes, base_addr == 0) &&
+	(void)(probe_list2(unit, m68k_probes, base_addr == 0) &&
 		probe_list2(unit, isa_probes, base_addr == 0));
 }
 
-- 
2.5.5
