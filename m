From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 5/8] watchdog: Drop references to H8300 architecture
Date: Fri, 30 Aug 2013 16:51:31 -0700
Message-ID: <1377906694-9578-6-git-send-email-linux@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Architecture is gone.

Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: Wim Van Sebroeck <wim@iguana.be>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/watchdog/Kconfig  |    2 --
 drivers/watchdog/Makefile |    2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/watchdog/Kconfig b/drivers/watchdog/Kconfig
index 362085d..08a8a4d 100644
--- a/drivers/watchdog/Kconfig
+++ b/drivers/watchdog/Kconfig
@@ -408,8 +408,6 @@ config BFIN_WDT
 
 # FRV Architecture
 
-# H8300 Architecture
-
 # X86 (i386 + ia64 + x86_64) Architecture
 
 config ACQUIRE_WDT
diff --git a/drivers/watchdog/Makefile b/drivers/watchdog/Makefile
index 2f26a0b..3989d3e 100644
--- a/drivers/watchdog/Makefile
+++ b/drivers/watchdog/Makefile
@@ -65,8 +65,6 @@ obj-$(CONFIG_BFIN_WDT) += bfin_wdt.o
 
 # FRV Architecture
 
-# H8300 Architecture
-
 # X86 (i386 + ia64 + x86_64) Architecture
 obj-$(CONFIG_ACQUIRE_WDT) += acquirewdt.o
 obj-$(CONFIG_ADVANTECH_WDT) += advantechwdt.o
-- 
1.7.9.7
