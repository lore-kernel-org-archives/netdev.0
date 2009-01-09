From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 01/16] dma-debug: add Kconfig entry
Date: Fri, 9 Jan 2009 17:19:15 +0100
Message-ID: <1231517970-20288-2-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:32087 "EHLO
	WA4EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbZAIQTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:44 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add a Kconfig entry for DMA-API debugging

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/Kconfig      |    2 ++
 lib/Kconfig.debug |   11 +++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 2e13aa2..068554c 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -103,3 +103,5 @@ config HAVE_CLK
 	  The <linux/clk.h> calls support software clock gating and
 	  thus are a key power management tool on many systems.
 
+config HAVE_DMA_API_DEBUG
+	bool
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2e75478..cba5778 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -899,6 +899,17 @@ config DYNAMIC_PRINTK_DEBUG
 	  debugging for all modules. This mode can be turned off via the above
 	  disable command.
 
+config DMA_API_DEBUG
+	bool "Enable debugging of DMA-API usage"
+	depends on HAVE_DMA_API_DEBUG
+	help
+	  Enable this option to debug the use of the DMA API by device drivers.
+	  With this option you will be able to detect common bugs in device
+	  drivers like double-freeing of DMA mappings or freeing mappings that
+	  were never allocated.
+	  This option causes a performance degredation.  Use only if you want
+	  to debug device drivers. If unsure, say N.
+
 source "samples/Kconfig"
 
 source "lib/Kconfig.kgdb"
-- 
1.5.6.4


