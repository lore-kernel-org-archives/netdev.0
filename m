From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 02/10] x86: add data structures for DMA-API debugging
Date: Fri, 21 Nov 2008 17:26:02 +0100
Message-ID: <1227284770-19215-3-git-send-email-joerg.roedel@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:5021 "EHLO
	WA4EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbYKUQ0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:22 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: adds a new header file for DMA-API debugging

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/include/asm/dma_debug.h |   41 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/include/asm/dma_debug.h

diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
new file mode 100644
index 0000000..d79f024
--- /dev/null
+++ b/arch/x86/include/asm/dma_debug.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (C) 2008 Advanced Micro Devices, Inc.
+ *
+ * Author: Joerg Roedel <joerg.roedel@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ */
+
+#ifndef __ASM_X86_DMA_DEBUG
+#define __ASM_X86_DMA_DEBUG
+
+/* Allocation flags */
+#define DMA_DEBUG_SINGLE        0
+#define DMA_DEBUG_SG            1
+#define DMA_DEBUG_COHERENT      2
+
+struct device;
+struct list_head;
+
+struct dma_debug_entry {
+	struct list_head list;
+	struct device *dev;
+	int type;
+	void *cpu_addr;
+	u64 dev_addr;
+	u64 size;
+	int direction;
+};
+
+#endif /* __ASM_X86_DMA_DEBUG */
-- 
1.5.6.4


