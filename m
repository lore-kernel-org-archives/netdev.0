From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 8/8] fs/minix: Drop dependency on H8300
Date: Fri, 30 Aug 2013 16:51:34 -0700
Message-ID: <1377906694-9578-9-git-send-email-linux@roeck-us.net>
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

The H8/300 architecture is gone. Drop dependencies on it.

Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 fs/minix/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/minix/Kconfig b/fs/minix/Kconfig
index 6624684..f2a0cfc 100644
--- a/fs/minix/Kconfig
+++ b/fs/minix/Kconfig
@@ -18,7 +18,7 @@ config MINIX_FS
 
 config MINIX_FS_NATIVE_ENDIAN
 	def_bool MINIX_FS
-	depends on H8300 || M32R || MICROBLAZE || MIPS || S390 || SUPERH || SPARC || XTENSA || (M68K && !MMU)
+	depends on M32R || MICROBLAZE || MIPS || S390 || SUPERH || SPARC || XTENSA || (M68K && !MMU)
 
 config MINIX_FS_BIG_ENDIAN_16BIT_INDEXED
 	def_bool MINIX_FS
-- 
1.7.9.7
