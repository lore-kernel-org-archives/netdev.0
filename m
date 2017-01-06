From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 3/7] nios2: put setup.h in uapi
Date: Fri,  6 Jan 2017 10:43:55 +0100
Message-ID: <1483695839-18660-4-git-send-email-nicolas.dichtel@6wind.com>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org,
 linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org,
 linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
 linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org,
 adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org,
 Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-me
To: arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This header file is exported, thus move it to uapi.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 arch/nios2/include/asm/setup.h      | 2 +-
 arch/nios2/include/uapi/asm/setup.h | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)
 create mode 100644 arch/nios2/include/uapi/asm/setup.h

diff --git a/arch/nios2/include/asm/setup.h b/arch/nios2/include/asm/setup.h
index dcbf8cf1a344..d49e9e91bf55 100644
--- a/arch/nios2/include/asm/setup.h
+++ b/arch/nios2/include/asm/setup.h
@@ -19,7 +19,7 @@
 #ifndef _ASM_NIOS2_SETUP_H
 #define _ASM_NIOS2_SETUP_H
 
-#include <asm-generic/setup.h>
+#include <uapi/asm/setup.h>
 
 #ifndef __ASSEMBLY__
 #ifdef __KERNEL__
diff --git a/arch/nios2/include/uapi/asm/setup.h b/arch/nios2/include/uapi/asm/setup.h
new file mode 100644
index 000000000000..8d8285997ba8
--- /dev/null
+++ b/arch/nios2/include/uapi/asm/setup.h
@@ -0,0 +1,6 @@
+#ifndef _UAPI_ASM_NIOS2_SETUP_H
+#define _UAPI_ASM_NIOS2_SETUP_H
+
+#include <asm-generic/setup.h>
+
+#endif /* _UAPI_ASM_NIOS2_SETUP_H */
-- 
2.8.1
