From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 16:57:06 +0100
Message-ID: <200802111657.07534.ossthema@de.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:56168 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbYBKP5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 10:57:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers like eHEA need memory notifiers in order to 
update their internal DMA memory map when memory is added
to or removed from the system.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


---
 Hi,

 this is the modified version with EXPORT_SYMBOL_GPL

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

