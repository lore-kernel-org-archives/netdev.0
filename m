From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 17:24:11 +0100
Message-ID: <200802111724.12416.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Themann, Jan-Bernd" <themann@de.ibm.com>,
	Greg KH <greg@kroah.com>, Christoph Raisch <RAISCH@de.ibm.com>
To: Dave Hansen <haveblue@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758838AbYBKQYs@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers like eHEA need memory notifiers in order to 
update their internal DMA memory map when memory is added
to or removed from the system.

Patch for eHEA memory hotplug support that uses these functions:
http://www.spinics.net/lists/netdev/msg54484.html

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


---
 Hi,

 the eHEA patch belongs to a patchset that is usually
 added by Jeff Garzik once this dependency (EXPORTS)
 is resolved.

 Regards,
 Jan-Bernd


 drivers/base/memory.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7ae413f..f5a0bf1 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -52,11 +52,13 @@ int register_memory_notifier(struct notifier_block *nb)
 {
         return blocking_notifier_chain_register(&memory_chain, nb);
 }
+EXPORT_SYMBOL_GPL(register_memory_notifier);
 
 void unregister_memory_notifier(struct notifier_block *nb)
 {
         blocking_notifier_chain_unregister(&memory_chain, nb);
 }
+EXPORT_SYMBOL_GPL(unregister_memory_notifier);
 
 /*
  * register_memory - Setup a sysfs device for a memory block
-- 
1.5.2
