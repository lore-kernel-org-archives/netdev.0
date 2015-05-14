From: Julien Grall <julien.grall@citrix.com>
Subject: [RFC 01/23] xen: Include xen/page.h rather than asm/xen/page.h
Date: Thu, 14 May 2015 18:00:41 +0100
Message-ID: <1431622863-28575-2-git-send-email-julien.grall@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<tim@xen.org>, Julien Grall <julien.grall@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using xen/page.h will be necessary later for using common xen page
helpers.

As xen/page.h already include asm/xen/page.h, always use the later.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
---
 arch/arm/xen/mm.c                  | 2 +-
 arch/arm/xen/p2m.c                 | 2 +-
 drivers/net/xen-netback/netback.c  | 2 +-
 drivers/net/xen-netfront.c         | 1 -
 drivers/xen/events/events_base.c   | 2 +-
 drivers/xen/events/events_fifo.c   | 2 +-
 drivers/xen/gntdev.c               | 2 +-
 drivers/xen/manage.c               | 2 +-
 drivers/xen/tmem.c                 | 2 +-
 drivers/xen/xenbus/xenbus_client.c | 2 +-
 10 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index 4983250..03e75fe 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -15,10 +15,10 @@
 #include <xen/xen.h>
 #include <xen/interface/grant_table.h>
 #include <xen/interface/memory.h>
+#include <xen/page.h>
 #include <xen/swiotlb-xen.h>
 
 #include <asm/cacheflush.h>
-#include <asm/xen/page.h>
 #include <asm/xen/hypercall.h>
 #include <asm/xen/interface.h>
 
diff --git a/arch/arm/xen/p2m.c b/arch/arm/xen/p2m.c
index cb7a14c..887596c 100644
--- a/arch/arm/xen/p2m.c
+++ b/arch/arm/xen/p2m.c
@@ -10,10 +10,10 @@
 
 #include <xen/xen.h>
 #include <xen/interface/memory.h>
+#include <xen/page.h>
 #include <xen/swiotlb-xen.h>
 
 #include <asm/cacheflush.h>
-#include <asm/xen/page.h>
 #include <asm/xen/hypercall.h>
 #include <asm/xen/interface.h>
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4de46aa..9c6a504 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -44,9 +44,9 @@
 #include <xen/xen.h>
 #include <xen/events.h>
 #include <xen/interface/memory.h>
+#include <xen/page.h>
 
 #include <asm/xen/hypercall.h>
-#include <asm/xen/page.h>
 
 /* Provide an option to disable split event channels at load time as
  * event channels are limited resource. Split event channels are
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3f45afd..ff88f31 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -45,7 +45,6 @@
 #include <linux/slab.h>
 #include <net/ip.h>
 
-#include <asm/xen/page.h>
 #include <xen/xen.h>
 #include <xen/xenbus.h>
 #include <xen/events.h>
diff --git a/drivers/xen/events/events_base.c b/drivers/xen/events/events_base.c
index 2b8553b..704d36e 100644
--- a/drivers/xen/events/events_base.c
+++ b/drivers/xen/events/events_base.c
@@ -39,8 +39,8 @@
 #include <asm/irq.h>
 #include <asm/idle.h>
 #include <asm/io_apic.h>
-#include <asm/xen/page.h>
 #include <asm/xen/pci.h>
+#include <xen/page.h>
 #endif
 #include <asm/sync_bitops.h>
 #include <asm/xen/hypercall.h>
diff --git a/drivers/xen/events/events_fifo.c b/drivers/xen/events/events_fifo.c
index 417415d..ed673e1 100644
--- a/drivers/xen/events/events_fifo.c
+++ b/drivers/xen/events/events_fifo.c
@@ -44,13 +44,13 @@
 #include <asm/sync_bitops.h>
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>
-#include <asm/xen/page.h>
 
 #include <xen/xen.h>
 #include <xen/xen-ops.h>
 #include <xen/events.h>
 #include <xen/interface/xen.h>
 #include <xen/interface/event_channel.h>
+#include <xen/page.h>
 
 #include "events_internal.h"
 
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 8927485..67b9163 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -41,9 +41,9 @@
 #include <xen/balloon.h>
 #include <xen/gntdev.h>
 #include <xen/events.h>
+#include <xen/page.h>
 #include <asm/xen/hypervisor.h>
 #include <asm/xen/hypercall.h>
-#include <asm/xen/page.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Derek G. Murray <Derek.Murray@cl.cam.ac.uk>, "
diff --git a/drivers/xen/manage.c b/drivers/xen/manage.c
index 9e6a851..d10effe 100644
--- a/drivers/xen/manage.c
+++ b/drivers/xen/manage.c
@@ -19,10 +19,10 @@
 #include <xen/grant_table.h>
 #include <xen/events.h>
 #include <xen/hvc-console.h>
+#include <xen/page.h>
 #include <xen/xen-ops.h>
 
 #include <asm/xen/hypercall.h>
-#include <asm/xen/page.h>
 #include <asm/xen/hypervisor.h>
 
 enum shutdown_state {
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index c4211a3..3718b4a 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -17,8 +17,8 @@
 
 #include <xen/xen.h>
 #include <xen/interface/xen.h>
+#include <xen/page.h>
 #include <asm/xen/hypercall.h>
-#include <asm/xen/page.h>
 #include <asm/xen/hypervisor.h>
 #include <xen/tmem.h>
 
diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index 96b2011..a014016 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -37,7 +37,7 @@
 #include <linux/vmalloc.h>
 #include <linux/export.h>
 #include <asm/xen/hypervisor.h>
-#include <asm/xen/page.h>
+#include <xen/page.h>
 #include <xen/interface/xen.h>
 #include <xen/interface/event_channel.h>
 #include <xen/balloon.h>
-- 
2.1.4
