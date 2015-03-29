From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 54/86] atheros/atlx: use uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 15:41:28 +0200
Message-ID: <1427635734-24786-55-git-send-email-mst@redhat.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Benoit Taine <benoit.taine@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>,
	Bjorn Helgaas <bhelgaas@google.com>,
	=?us-ascii?B?PT9VVEYtOD9xP2ZyYW49QzM9QTdvaXM9MjByb21pZXU/PQ==?=
	<romieu@fr.zoreil.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427635734-24786-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
use the new header directly so we can drop
the wrapper in include/linux/pci_ids.h.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index eca1d11..774667b 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -67,7 +67,7 @@
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/pm.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 46a5353..bdb9dfe 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -36,7 +36,7 @@
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/pm.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
-- 
MST
