From: akpm@osdl.org
Subject: [patch 8/9] AES: allow modular build
Date: Thu, 28 Oct 2004 00:19:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Lk908015@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, pluto@pld-linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: <pluto@pld-linux.org>


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/i386/crypto/Makefile |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/i386/crypto/Makefile~aes-allow-modular-build arch/i386/crypto/Makefile
--- 25/arch/i386/crypto/Makefile~aes-allow-modular-build	2004-10-28 00:17:08.598496816 -0700
+++ 25-akpm/arch/i386/crypto/Makefile	2004-10-28 00:17:08.603496056 -0700
@@ -6,4 +6,4 @@
 
 obj-$(CONFIG_CRYPTO_AES_586) += aes-i586.o
 
-aes-i586-y := aes-i586-asm.o aes.o
+aes-i586-objs := aes-i586-asm.o aes.o
_
